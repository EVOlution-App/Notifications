import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class User: Model {
    let storage = Storage()
    static let entity = "User"
    
    var ckID        : String
    var tagsID      : [Identifier]
    var updatedAt   : Date
    var createdAt   : Date
    
    var tags: [Tag] {
        let values: [Tag] = tagsID.flatMap { item in
            guard let id = item.string else {
                return nil
            }
            
            guard let tag = try? Tag.get(by: id) else {
                return nil
            }
            
            return tag
        }
        
        return values
    }

    struct Keys {
        static let ckID         = "ckID"
        static let tags         = "tags"
        static let updatedAt    = "updatedAt"
        static let createdAt    = "createdAt"
    }
    
    init(identifier: String,
         tags: [Identifier],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        
        self.ckID       = identifier
        self.tagsID     = tags
        self.updatedAt  = updatedAt
        self.createdAt  = createdAt
    }
    
    init(row: Row) throws {
        ckID        = try row.get(User.Keys.ckID)
        tagsID      = try row.get(User.Keys.tags)
        updatedAt   = try row.get(User.Keys.updatedAt)
        createdAt   = try row.get(User.Keys.createdAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.ckID, ckID)
        try row.set(User.Keys.updatedAt, updatedAt)
        try row.set(User.Keys.createdAt, createdAt)
        try row.set(User.Keys.tags, tagsID)
        
        return row
    }
}

// MARK: - Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.Keys.ckID)
            builder.custom("tags", type: "[Identifier]")
            builder.date(User.Keys.updatedAt)
            builder.date(User.Keys.createdAt)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            identifier: try json.get(User.Keys.ckID),
            tags: try json.get(User.Keys.tags)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.ckID, ckID)
        try json.set(User.Keys.updatedAt, updatedAt)
        try json.set(User.Keys.createdAt, createdAt)

        try json.set(User.Keys.tags, tags)
        
        return json
    }
}

// MARK: - HTTP
extension User: ResponseRepresentable { }

// MARK: - Update
extension User: Updateable {
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey(User.Keys.ckID, String.self) { device, ckID in
                device.ckID = ckID
            },
            UpdateableKey(User.Keys.tags, [Identifier].self) { device, tags in
                device.tagsID = tags
            },
            UpdateableKey(User.Keys.updatedAt, Date.self) { device, updatedAt in
                device.updatedAt = updatedAt
            }
        ]
    }
}

// MARK: - Query
extension User {
    public static func get(by id: String) throws -> User? {
        let query = try User.makeQuery()
        let user = try query.filter("ckID" == id).first()
        
        return user
    }
}
