import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Tag: Model {
    let storage = Storage()
    static let entity = "Tag"
    
    var name        : String
    var createdAt   : Date
    var updatedAt   : Date

    struct Keys {
        static let name         = "name"
        static let createdAt    = "createdAt"
        static let updatedAt    = "updatedAt"
    }
    
    init(name: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {

        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(row: Row) throws {
        name      = try row.get(Tag.Keys.name)
        createdAt   = try row.get(Tag.Keys.createdAt)
        updatedAt   = try row.get(Tag.Keys.updatedAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Tag.Keys.name, name)
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
            name: try json.get(Tag.Keys.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Tag.Keys.name, name)
        try json.set(Tag.Keys.createdAt, createdAt)
        try json.set(Tag.Keys.updatedAt, updatedAt)
        
        return json
    }
}

// MARK: HTTP
extension Tag: ResponseRepresentable { }

// MARK: Update
extension Tag: Updateable {
    public static var updateableKeys: [UpdateableKey<Tag>] {
        return [
            UpdateableKey(Tag.Keys.name, String.self) { device, name in
                device.name = name
            },
            UpdateableKey(Tag.Keys.updatedAt, Date.self) { device, updatedAt in
                device.updatedAt = updatedAt
            }
        ]
    }
}

