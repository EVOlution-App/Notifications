import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Notification: Model {
    let storage = Storage()
    static let entity = "Notification"
    
    init() {}
    init(row: Row) throws {}
    
    func makeRow() throws -> Row {
        let row = Row()
        return row
    }
}

// MARK: - Preparation
extension Notification: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - Query
extension Notification {
    public static func get(by id: String) throws -> Notification? {
        let query = try Notification.makeQuery()
        guard let notification = try query.filter("_id", id).first() else {
            return nil
        }
        
        return notification
    }
    
    public static func get(by id: Identifier) throws -> Notification? {
        guard let value = id.string else {
            return nil
        }
        
        return try Notification.get(by: value)
    }
}
