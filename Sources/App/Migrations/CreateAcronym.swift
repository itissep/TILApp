//
//  File.swift
//  
//
//  Created by The GORDEEVS on 14.07.2022.
//

import Foundation
import Fluent
import Vapor

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
}


struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
