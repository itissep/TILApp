//
//  File.swift
//  
//
//  Created by The GORDEEVS on 16.07.2022.
//

import Foundation
@testable import App
import XCTVapor

final class AcronymTests: XCTestCase {
    let acronymShort = "OMG"
    let acronymLong = "Oh My God"
    let acronymsURL = "/api/acronyms/"
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testAcronymsCanBeRetrievedFromAPI() throws {
        let user = try User.create(on: app.db)
        
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        _ = try Acronym.create(on: app.db)
        
        try app.test(.GET, acronymsURL, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
            XCTAssertEqual(acronyms[0].id, acronym.id)
        })
    }
    
    func testAcronymCanBeSavedWithApi() throws {
        let user = try User.create(on: app.db)
        let acronym = CreateAcronymData(short: acronymShort, long: acronymLong, userID: user.id!)
        
        try app.test(.POST, acronymsURL, beforeRequest: { req in
            try req.content.encode(acronym)
        }, afterResponse: { response in
            let receivedAcronym = try response.content.decode(Acronym.self)
            XCTAssertEqual(receivedAcronym.short, acronymShort)
            XCTAssertEqual(receivedAcronym.long, acronymLong)
            XCTAssertNotNil(receivedAcronym.id)
            
            try app.test(.GET, acronymsURL, afterResponse: { secondResponse in
                let acronyms = try secondResponse.content.decode([Acronym].self)
                
                XCTAssertEqual(acronyms[0].short, acronymShort)
                XCTAssertEqual(acronyms[0].long, acronymLong)
                XCTAssertEqual(acronyms[0].id, receivedAcronym.id)
                
            })
        })
    }
    
    func testGettingASingleAcronymFromAPI() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        
        try app.test(.GET, "\(acronymsURL)\(acronym.id!)", afterResponse: { response in
            let receivedAcronym = try response.content.decode(Acronym.self)
            XCTAssertEqual(receivedAcronym.short, acronymShort)
            XCTAssertEqual(receivedAcronym.long, acronymLong)
            XCTAssertEqual(receivedAcronym.id, acronym.id)
            
        })
    }
    
    func testUpdatingAnAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        
        let newUser = try User.create(on: app.db)
        let newLong = "Something new"
        
        let newAcronym = CreateAcronymData(short: acronymShort, long: newLong, userID: newUser.id!)
        
        try app.test(.PUT, "\(acronymsURL)\(acronym.id!)", beforeRequest: { req in
            try req.content.encode(newAcronym)
        })
        
        try app.test(.GET, "\(acronymsURL)\(acronym.id!)", afterResponse: { response in
            let recievedAcronym = try response.content.decode(Acronym.self)
            
            XCTAssertEqual(recievedAcronym.short, acronym.short)
            XCTAssertEqual(recievedAcronym.long, newLong)
            XCTAssertEqual(recievedAcronym.$user.id, newUser.id)
            
        })
    }
    
    func testDeleteAnAcronym() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        
        try app.test(.GET, acronymsURL, afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 1)
        })
        
        try app.test(.DELETE, "\(acronymsURL)\(acronym.id!)")
        
        try app.test(.GET, acronymsURL, afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 0)
        })
    }
    
    func testSearchAcronymShort() throws {
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, on: app.db)
        
        try app.test(.GET, "\(acronymsURL)search?term=\(acronymShort)", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].id, acronym.id)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
        })
    }
    
    func testSearchAcronymBoth() throws {
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, on: app.db)
        
        try app.test(.GET, "\(acronymsURL)search/both?term=Oh+My+God", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].id, acronym.id)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
        })
        
        try app.test(.GET, "\(acronymsURL)search/both?term=\(acronymShort)", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 1)
            XCTAssertEqual(acronyms[0].id, acronym.id)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
        })
    }
    
    func testGetFirstAcronym() throws {
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, on: app.db)
        _ = try Acronym.create(on: app.db)
        
        try app.test(.GET, "\(acronymsURL)first", afterResponse: { response in
            let receivedAcronym = try response.content.decode(Acronym.self)
            XCTAssertEqual(receivedAcronym.id, acronym.id)
            XCTAssertEqual(receivedAcronym.short, acronymShort)
            XCTAssertEqual(receivedAcronym.long, acronymLong)
        })
        
    }
    
    func testSortingAcronyms() throws {
        
        let acronymSecond = try Acronym.create(short: "BCA", long: acronymLong, on: app.db)
        let acronymShouldBeFirst = try Acronym.create(short: "ABC", long: acronymLong, on: app.db)
        
        try app.test(.GET, "\(acronymsURL)sorted", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms[0].id, acronymShouldBeFirst.id)
            XCTAssertEqual(acronyms[0].short, acronymShouldBeFirst.short)
            XCTAssertEqual(acronyms[0].long, acronymShouldBeFirst.long)
        })
    }
    
    func testGettingAnAcronymsUser() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        
        try app.test(.GET, "\(acronymsURL)\(acronym.id!)/user", afterResponse: { response in
            let receivedUser = try response.content.decode(User.self)
            XCTAssertEqual(receivedUser.id, user.id)
            XCTAssertEqual(receivedUser.name, user.name)
            XCTAssertEqual(receivedUser.username, user.username)
        })
    }
    
    func testAcronymsCategories() throws {
        let user = try User.create(on: app.db)
        let acronym = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: app.db)
        let category = try App.Category.create(on: app.db)
        
        try app.test(.POST, "\(acronymsURL)\(acronym.id!)/categories/\(category.id!)")
        
        try app.test(.GET, "\(acronymsURL)\(acronym.id!)/categories", afterResponse: { response in
            let categories = try response.content.decode([App.Category].self)
            XCTAssertEqual(categories[0].id, category.id)
            XCTAssertEqual(categories[0].name, category.name)
        })
    }
    
}
