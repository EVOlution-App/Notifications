import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Tag: Model {
    let storage = Storage()
    static let entity = "Tag"
    
    var name        : String
    var identifier  : String
    var appID       : Identifier
    var createdAt   : Date
    var updatedAt   : Date

    var app: Parent<Tag, App> {
        return parent(id: appID)
    }
    
    struct Keys {
        static let name         = "name"
        static let identifier   = "identifier"
        static let app          = "app"
        static let createdAt    = "createdAt"
        static let updatedAt    = "updatedAt"
    }
    
    init(name: String,
         appID: Identifier,
         identifier: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {

        self.name = name
        self.appID = appID
        self.identifier = identifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(row: Row) throws {
        name        = try row.get(Tag.Keys.name)
        appID       = try row.get(Tag.Keys.app)
        identifier  = try row.get(Tag.Keys.identifier)
        createdAt   = try row.get(Tag.Keys.createdAt)
        updatedAt   = try row.get(Tag.Keys.updatedAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Tag.Keys.name, name)
        try row.set(Tag.Keys.app, appID)
        try row.set(Tag.Keys.identifier, identifier)
        try row.set(Tag.Keys.createdAt, createdAt)
        try row.set(Tag.Keys.updatedAt, updatedAt)
        
        return row
    }
}

// MARK: - Preparation
extension Tag: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Tag.Keys.name)
            builder.string(Tag.Keys.app)
            builder.string(Tag.Keys.identifier)
            builder.date(Tag.Keys.createdAt)
            builder.date(Tag.Keys.updatedAt)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension Tag: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Tag.Keys.name),
            appID: try json.get(Tag.Keys.app),
            identifier: try json.get(Tag.Keys.identifier)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Tag.idKey, id)
        try json.set(Tag.Keys.name, name)
        try json.set(Tag.Keys.identifier, identifier)
        
        return json
    }
}

// MARK: HTTP
extension Tag: ResponseRepresentable { }

// MARK: - Query
extension Tag {
    public static func get(by id: String) throws -> Tag? {
        let query = try Tag.makeQuery()
        guard let tag = try query.filter("_id", id).first() else {
            return nil
        }
        
        return tag
    }
    
    public static func get(by id: Identifier) throws -> Tag? {
        guard let value = id.string else {
            return nil
        }
        
        return try Tag.get(by: value)
    }
}
