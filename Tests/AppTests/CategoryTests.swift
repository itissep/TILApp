//
//  File.swift
//  
//
//  Created by The GORDEEVS on 16.07.2022.
//

import Foundation
@testable import App
import XCTVapor

final class CategoryTests: XCTestCase {
    
    
    let categorysName = "Random"
    let categoriesURI = "/api/categories/"
    var app: Application!
    
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testCategoriesCanBeRetrievedFromAPI() throws {
        let category = try App.Category.create(name: categorysName, on: app.db)
        _ = try App.Category.create(on: app.db)
        try app.test(.GET, categoriesURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let categories = try response.content.decode([App.Category].self)
            
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, categorysName)
            XCTAssertEqual(categories[0].id, category.id)
            
        })
    }
    
    func testCategoryCanBeSavedWithAPI() throws {
        let category = App.Category(name: categorysName)
        
        try app.test(.POST, categoriesURI, beforeRequest: {
            req in
            try req.content.encode(category)
        
        }, afterResponse: { response in
            let recievedCategory = try response.content.decode(App.Category.self)
            XCTAssertEqual(recievedCategory.name, categorysName)
            XCTAssertNotNil(recievedCategory.id)
            
            try app.test(.GET, categoriesURI, afterResponse: { secondResponse in
                let categories = try secondResponse.content.decode([App.Category].self)
                XCTAssertEqual(categories[0].id, recievedCategory.id)
                XCTAssertEqual(categories[0].name, categorysName)
            })
        })
    }
    
    func testGettingASingleCategoryFromAPI() throws {
        let category = try App.Category.create(name: categorysName, on: app.db)
        
        try app.test(.GET, "\(categoriesURI)\(category.id!)", afterResponse: { response in
            let receivedCategory = try response.content.decode(App.Category.self)
            
            XCTAssertEqual(receivedCategory.id, category.id)
            XCTAssertEqual(receivedCategory.name, categorysName)
            
        })
    }
    
    func testGettingACategoriesAcronymsFromAPI() throws {
        let category = try App.Category.create(name: categorysName, on: app.db)
        
        let acronymShort = "LOL"
        let acronymLong = "Laught out laud"
        
        let acronym1 = try Acronym.create(short: acronymShort , long: acronymLong, on: app.db)
        let acronym2 = try Acronym.create(on: app.db)
        
        let apiURL = "/api/acronyms/"
        
        try app.test(.POST, "\(apiURL)\(acronym1.id!)/categories/\(category.id!)")
        try app.test(.POST, "\(apiURL)\(acronym2.id!)/categories/\(category.id!)")
        
        try app.test(.GET, "\(categoriesURI)\(category.id!)/acronyms", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].id, acronym1.id)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
        })
    }
}
