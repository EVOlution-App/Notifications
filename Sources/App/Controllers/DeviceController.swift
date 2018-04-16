import Vapor
import HTTP

final class DeviceController {
  
    
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
            throw Abort(Status.unprocessableEntity, reason: "Missing 'token' parameter")
        }
        
        guard let userID = json["user"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "Missing 'user' parameter")
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
        
        let language    = json["language"]?.string
        let model       = json["model"]?.string
        let os          = json["os"]?.string
        
        guard let device = try Device.get(by: token, and: user) else {
            // New device
            let device = try request.device()
            device.appID = key

            try device.save()

            return device
        }

        device.appID        = key
        device.token        = token
        device.user         = try user.assertExists()

        device.os           = os
        device.model        = model
        device.language     = language
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

extension DeviceController: EmptyInitializable {}
