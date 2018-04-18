import Vapor
import HTTP

final class DeviceController {
    private var drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func show(_ request: Request) throws -> ResponseRepresentable {
        try AuthorizationProvider.checkAPIKey(request)
        
        guard let token = request.parameters["token"]?.string else {
            throw Abort(Status.notFound, reason: "token is required")
        }

        let query = try Device.makeQuery()
        guard let device = try query.filter("token", token).first() else {
            throw Abort(Status.notFound, reason: "token could be found")
        }
        
        return device
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        let key = try AuthorizationProvider.checkAPIKey(request)

        guard let json = request.json else {
            throw Abort.badRequest
        }
        
        guard let token = json["token"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "'token' is required")
        }
        
        guard let userID = json["user"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "'user' is required")
        }
        
        guard json["platform"]?.string != nil else {
            throw Abort(Status.unprocessableEntity, reason: "'platform' is required")
        }
        
        
        var user: User
        if let value = try User.get(by: userID) {
            user = value
        }
        else {
            // New user
            let newUser = User(identifier: userID, tags: [])
            
            // Register current tags avaiable to user
            let tags: [Identifier] = try Tag.all().flatMap { tag in
                return try? tag.assertExists()
            }
            newUser.tagsID = tags
            
            try newUser.save()
            user = newUser
        }
        
        let test        = json["test"]?.bool ?? false
        let language    = json["language"]?.string
        let model       = json["model"]?.string
        let os          = json["os"]?.string
        let appVersion  = json["appVersion"]?.string
        
        // Register device at OneSignal
        guard let oneSignalDevice = OneSignal.Device.create(with: token, using: json) else {
            throw Abort(.badRequest)
        }
        
        guard let registration = try OneSignal.Request.register(oneSignalDevice, using: drop), registration.success else {
                throw Abort(.internalServerError)
        }
        
        guard let device = try Device.get(by: token, and: user) else {
            // New device
            let device       = try request.device()
            device.user      = try user.assertExists()
            device.appID     = key
            device.onesignal = registration.id
            try device.save()

            return device
        }

        device.test         = test
        device.os           = os
        device.appVersion   = appVersion
        device.model        = model
        device.language     = language
        device.onesignal    = registration.id
        device.updatedAt    = Date()
        try device.save()

        return device
    }
}

extension Request {
    func device() throws -> Device {
        guard let json = json else {
            throw Abort.badRequest
        }

        return try Device(json: json)
    }
}
