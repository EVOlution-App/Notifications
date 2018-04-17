import Vapor
import FluentProvider
import HTTP

// MARK: - Device model
final class Device: Model {
    let storage = Storage()
    static let entity = "Device"
    
    var token       : String
    var user        : Identifier
    var test        : Bool = false
    var os          : String?
    var model       : String?
    var language    : String?
    var appID       : Identifier
    var createdAt   : Date?
    var updatedAt   : Date?
    
    var app: Parent<Device, App> {
        return parent(id: appID)
    }
    
    struct Keys {
        static let id           = "id"
        static let token        = "token"
        static let user         = "user"
        static let test         = "test"
        static let os           = "os"
        static let model        = "model"
        static let language     = "language"
        static let app          = "app"
        static let createdAt    = "createdAt"
        static let updatedAt    = "updatedAt"
    }
    
    init(token: String,
         user: Identifier,
         test: Bool = false,
         os: String? = nil,
         model: String? = nil,
         language: String? = nil,
         appID: Identifier,
         createdAt: Date? = Date(),
         updatedAt: Date? = Date()) {
        
        self.token          = token
        self.user           = user
        self.test           = test
        self.os             = os
        self.model          = model
        self.language       = language
        self.appID          = appID
        self.createdAt      = createdAt
        self.updatedAt      = updatedAt
    }
    
    init(row: Row) throws {
        token  = try row.get(Device.Keys.token)
        user      = try row.get(Device.Keys.user)
        test        = try row.get(Device.Keys.test)
        os          = try row.get(Device.Keys.os)
        model       = try row.get(Device.Keys.model)
        language    = try row.get(Device.Keys.language)
        appID       = try row.get(Device.Keys.app)
        createdAt   = try row.get(Device.Keys.createdAt)
        updatedAt   = try row.get(Device.Keys.updatedAt)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Device.Keys.token, token)
        try row.set(Device.Keys.user, user)
        try row.set(Device.Keys.test, test)
        try row.set(Device.Keys.os, os)
        try row.set(Device.Keys.model, model)
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
            builder.string(Device.Keys.token)
            builder.string(Device.Keys.user)
            builder.bool(Device.Keys.test)
            builder.string(Device.Keys.os)
            builder.string(Device.Keys.model)
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
            token:      try json.get(Device.Keys.token),
            user:       try json.get(Device.Keys.user),
            test:       try json.get(Device.Keys.test),
            os:         try json.get(Device.Keys.os),
            model:      try json.get(Device.Keys.model),
            language:   try json.get(Device.Keys.language),
            appID:      try json.get(Device.Keys.app)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Device.Keys.token, token)
        try json.set(Device.Keys.user, user)
        try json.set(Device.Keys.test, test)
        try json.set(Device.Keys.os, os)
        try json.set(Device.Keys.model, model)
        try json.set(Device.Keys.language, language)
        try json.set(Device.Keys.createdAt, createdAt)
        try json.set(Device.Keys.updatedAt, updatedAt)
        
        return json
    }
}

// MARK: - HTTP
extension Device: ResponseRepresentable { }

// MARK: - Update
extension Device: Updateable {
    public static var updateableKeys: [UpdateableKey<Device>] {
        return [
            UpdateableKey(Device.Keys.token, String.self) { device, token in
                device.token = token
            },
            UpdateableKey(Device.Keys.user, Identifier.self) { device, user in
                device.user = user
            },
            UpdateableKey(Device.Keys.test, Bool.self) { device, test in
                device.test = test
            },
            UpdateableKey(Device.Keys.os, String.self) { device, os in
                device.os = os
            },
            UpdateableKey(Device.Keys.model, String.self) { device, model in
                device.model = model
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

// MARK: - Query
extension Device {
    public static func get(by token: String, user: Identifier) throws -> Device? {
        let query = try Device.makeQuery()
        let device = try query.and { andGroup in
            try andGroup.filter("user", user)
            try andGroup.filter("token", token)
        }.first()

        return device
    }
    
    public static func get(by token: String, and user: User) throws -> Device? {
        
        return try Device.get(by: token,
                              user: user.assertExists())
    }
}
