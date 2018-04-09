import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Device: Model {
    let storage = Storage()
    static let entity = "Device"
    
    var identifier: String
    var owner:     String
    var test:       Bool = false
    var subscribed: Bool = true
    var os:         String?
    var model:      String?
    var tags:       [JSON]?
    var language:   String?
    var appID:      Identifier
    var createdAt:  Date?
    var updatedAt:  Date?
    
    var app: Parent<Device, App> {
        return parent(id: appID)
    }
    
    struct Keys {
        static let id           = "id"
        static let identifier   = "identifier"
        static let owner       = "owner"
        static let test         = "test"
        static let subscribed   = "subscribed"
        static let os           = "os"
        static let model        = "model"
        static let tags         = "tags"
        static let language     = "language"
        static let app          = "app"
        static let createdAt    = "createdAt"
        static let updatedAt    = "updatedAt"
    }
    
    init(identifier: String,
         owner: String,
         test: Bool = false,
         subscribed: Bool = true,
         os: String? = nil,
         model: String? = nil,
         tags: [JSON]? = nil,
         language: String? = nil,
         appID: Identifier,
         createdAt: Date? = Date(),
         updatedAt: Date? = Date()) {
        
        self.identifier = identifier
        self.owner = owner
        self.test = test
        self.subscribed = subscribed
        self.os = os
        self.model = model
        self.tags = tags
        self.language = language
        self.appID = appID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(row: Row) throws {
        identifier  = try row.get(Device.Keys.identifier)
        owner      = try row.get(Device.Keys.owner)
        test        = try row.get(Device.Keys.test)
        subscribed  = try row.get(Device.Keys.subscribed)
        os          = try row.get(Device.Keys.os)
        model       = try row.get(Device.Keys.model)
        tags        = try row.get(Device.Keys.tags)
        language    = try row.get(Device.Keys.language)
        appID       = try row.get(Device.Keys.app)
        createdAt   = try row.get(Device.Keys.createdAt)
        updatedAt   = try row.get(Device.Keys.updatedAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Device.Keys.identifier, identifier)
        try row.set(Device.Keys.owner, owner)
        try row.set(Device.Keys.test, test)
        try row.set(Device.Keys.subscribed, subscribed)
        try row.set(Device.Keys.os, os)
        try row.set(Device.Keys.model, model)
        try row.set(Device.Keys.tags, tags)
        try row.set(Device.Keys.language, language)
        try row.set(Device.Keys.app, appID)
        try row.set(Device.Keys.createdAt, createdAt)
        try row.set(Device.Keys.updatedAt, updatedAt)
        
        return row
    }
}

// MARK: - Preparation
extension Device: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Device.Keys.identifier)
            builder.string(Device.Keys.owner)
            builder.bool(Device.Keys.test)
            builder.bool(Device.Keys.subscribed)
            builder.string(Device.Keys.os)
            builder.string(Device.Keys.model)
            builder.custom(Device.Keys.tags, type: "[JSON]]")
            builder.string(Device.Keys.language)
            builder.string(Device.Keys.app)
            builder.date(Device.Keys.createdAt)
            builder.date(Device.Keys.updatedAt)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON
extension Device: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            identifier: try json.get(Device.Keys.identifier),
            owner:     try json.get(Device.Keys.owner),
            test:       try json.get(Device.Keys.test),
            subscribed: try json.get(Device.Keys.subscribed),
            os:         try json.get(Device.Keys.os),
            model:      try json.get(Device.Keys.model),
            tags:       try json.get(Device.Keys.tags),
            language:   try json.get(Device.Keys.language),
            appID:      try json.get(Device.Keys.app)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Device.Keys.identifier, identifier)
        try json.set(Device.Keys.owner, owner)
        try json.set(Device.Keys.test, test)
        try json.set(Device.Keys.subscribed, subscribed)
        try json.set(Device.Keys.os, os)
        try json.set(Device.Keys.model, model)
        try json.set(Device.Keys.tags, tags)
        try json.set(Device.Keys.language, language)
        try json.set(Device.Keys.createdAt, createdAt)
        try json.set(Device.Keys.updatedAt, updatedAt)
        
        return json
    }
}

// MARK: HTTP
extension Device: ResponseRepresentable { }

// MARK: Update
extension Device: Updateable {
    public static var updateableKeys: [UpdateableKey<Device>] {
        return [
            UpdateableKey(Device.Keys.identifier, String.self) { device, identifier in
                device.identifier = identifier
            },
            UpdateableKey(Device.Keys.owner, String.self) { device, owner in
                device.owner = owner
            },
            UpdateableKey(Device.Keys.test, Bool.self) { device, test in
                device.test = test
            },
            UpdateableKey(Device.Keys.subscribed, Bool.self) { device, subscribed in
                device.subscribed = subscribed
            },
            UpdateableKey(Device.Keys.os, String.self) { device, os in
                device.os = os
            },
            UpdateableKey(Device.Keys.model, String.self) { device, model in
                device.model = model
            },
            UpdateableKey(Device.Keys.tags, [JSON].self) { device, tags in
                device.tags = tags
            },
            UpdateableKey(Device.Keys.language, String.self) { device, language in
                device.language = language
            },
            UpdateableKey(Device.Keys.updatedAt, Date.self) { device, updatedAt in
                device.updatedAt = updatedAt
            }
        ]
    }
}
