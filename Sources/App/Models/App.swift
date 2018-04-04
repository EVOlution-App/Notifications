import Vapor
import FluentProvider
import HTTP

// MARK: App model
final class App: Model {
    let storage = Storage()
    static let entity = "App"
    
    var name: String
    var key: String
    var createdAt:  Date
    var updatedAt:  Date
    
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let key = "key"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        
    }
    
    init(name: String,
         key: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.name = name
        self.key = key
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(row: Row) throws {
        name        = try row.get(App.Keys.name)
        key         = try row.get(App.Keys.key)
        createdAt   = try row.get(App.Keys.createdAt)
        updatedAt   = try row.get(App.Keys.updatedAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(App.Keys.name, name)
        try row.set(App.Keys.key, key)
        try row.set(App.Keys.createdAt, createdAt)
        try row.set(App.Keys.updatedAt, updatedAt)
        
        return row
    }
}


// MARK: - Preparation
extension App: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(App.Keys.name)
            builder.string(App.Keys.key)
            builder.string(App.Keys.createdAt)
            builder.string(App.Keys.updatedAt)
        }
    }
    
    static func loadFixtures() throws {
        let uuid = UUID().uuidString
        let app = App(name: "EVOlution App", key: uuid)
        
        try app.save()
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension App: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(App.Keys.name),
            key: try json.get(App.Keys.key)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(App.Keys.id, id)
        try json.set(App.Keys.name, name)
        try json.set(App.Keys.key, key)
        try json.set(App.Keys.createdAt, createdAt)
        try json.set(App.Keys.updatedAt, updatedAt)
        
        return json
    }
}

// MARK: HTTP
extension App: ResponseRepresentable { }

// MARK: Update
extension App: Updateable {
    public static var updateableKeys: [UpdateableKey<App>] {
        return [
            UpdateableKey(App.Keys.name, String.self) { app, name in
                app.name = name
            },
            UpdateableKey(App.Keys.key, String.self) { app, key in
                app.key = key
            },
            UpdateableKey(App.Keys.updatedAt, Date.self) { device, updatedAt in
                device.updatedAt = updatedAt
            }
        ]
    }
}
