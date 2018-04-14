import Vapor
import FluentProvider
import HTTP


public enum SourceTrack: String {
    case ios
    case macos
    case safari
    case chrome
}

// MARK: - Track model
final class Track: Model {
    let storage = Storage()
    static let entity = "Track"
    
    var notification : Identifier
    var user         : Identifier
    var source       : String
    var createdAt    : Date
    
    struct Keys {
        static let notification = "notification"
        static let user         = "user"
        static let source       = "source"
        static let createdAt    = "createdAt"
    }
    
    init(notification: Identifier,
         user: Identifier,
         source: String,
         createdAt: Date = Date()) {
        
        self.notification   = notification
        self.user           = user
        self.source         = source
        self.createdAt      = createdAt
    }
    
    init(row: Row) throws {
        notification    = try row.get(Track.Keys.notification)
        user            = try row.get(Track.Keys.user)
        source          = try row.get(Track.Keys.source)
        createdAt       = try row.get(Track.Keys.createdAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Track.Keys.notification, notification)
        try row.set(Track.Keys.user, user)
        try row.set(Track.Keys.source, source)
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
            builder.string(Track.Keys.source)
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
            user: try json.get(Track.Keys.user),
            source: try json.get(Track.Keys.source)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Track.Keys.notification, notification)
        try json.set(Track.Keys.user, user)
        try json.set(Track.Keys.source, source)
        try json.set(Track.Keys.createdAt, createdAt)
        
        return json
    }
}

// MARK: HTTP
extension Track: ResponseRepresentable { }
