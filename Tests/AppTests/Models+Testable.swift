//
//  File.swift
//  
//
//  Created by The GORDEEVS on 16.07.2022.
//

import Foundation
@testable import App
import Fluent

extension User {
    static func create(
        name: String = "Luke",
        username: String = "lukes",
        on database: Database
    ) throws -> User {
        let user = User(name: name, username: username)
        try user.save(on: database).wait()
        return user
    }
}

extension Acronym {
    static func create(short: String = "IKR" ,
                       long: String = "I Know Right",
                       user: User? = nil,
                       on database: Database
    ) throws -> Acronym {
        var acronymUser = user
        if acronymUser == nil {
            acronymUser = try User.create(on: database)
        }
        let acronym = Acronym(short: short, long: long, userID: acronymUser!.id!)
        try acronym.save(on: database).wait()
        return acronym
    }
}


extension App.Category {
    static func create(
        name: String = "Random",
        on database: Database
    ) throws -> App.Category {
        let category = Category(name: name)
        try category.save(on: database).wait()
        return category
    }
}
