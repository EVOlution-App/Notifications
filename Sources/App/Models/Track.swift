import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Track: Model {
    let storage = Storage()
    static let entity = "Track"
    
    var notification : Identifier
    var user         : Identifier
    var createdAt    : Date
    
    struct Keys {
        static let notification = "name"
        static let user         = "user"
        static let createdAt    = "createdAt"
    }
    
    init(notification: Identifier,
         user: Identifier,
         createdAt: Date = Date()) {
        
        self.notification = notification
        self.user = user
        self.createdAt = createdAt
    }
    
    init(row: Row) throws {
        notification = try row.get(Track.Keys.notification)
        user = try row.get(Track.Keys.user)
        createdAt = try row.get(Track.Keys.createdAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Track.Keys.notification, notification)
        try row.set(Track.Keys.user, user)
        try row.set(Track.Keys.createdAt, createdAt)
        
        return row
    }
}

// MARK: - Preparation
extension Track: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Track.Keys.notification)
            builder.string(Track.Keys.user)
            builder.date(Track.Keys.createdAt)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension Track: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            notification: try json.get(Track.Keys.notification),
            user: try json.get(Track.Keys.user)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Track.Keys.notification, notification)
        try json.set(Track.Keys.user, user)
        try json.set(Track.Keys.createdAt, createdAt)
        
        return json
    }
}

// MARK: HTTP
extension Track: ResponseRepresentable { }

// MARK: Update
extension Track: Updateable {
    public static var updateableKeys: [UpdateableKey<Track>] {
        return [
            UpdateableKey(Track.Keys.notification, Identifier.self) { device, notification in
                device.notification = notification
            },
            UpdateableKey(Track.Keys.user, Identifier.self) { device, user in
                device.user = user
            },
            UpdateableKey(Track.Keys.createdAt, Date.self) { device, createdAt in
                device.createdAt = createdAt
            }
        ]
    }
}

