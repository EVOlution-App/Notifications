import Vapor
import HTTP

final class UserController {
    func show(_ request: Request) throws -> ResponseRepresentable {
        try AuthorizationProvider.checkAPIKey(request)
        
        guard let userID = request.parameters["id"]?.string else {
            throw Abort(.notFound, reason: "'userid' is required")
        }
        
        guard let user = try User.get(by: userID) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return try user.makeJSON()
    }

    func updateTags(_ request: Request) throws -> ResponseRepresentable {
        try AuthorizationProvider.checkAPIKey(request)
        
        guard let json = request.json else {
            throw Abort.badRequest
        }
        
        guard let userID = request.parameters["id"]?.string else {
            throw Abort(.notFound, reason: "'userid' is required")
        }

        guard let user = try User.get(by: userID) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        if let notifications = json["notifications"]?.bool {
            user.tagsID = []

            if notifications {
                // Register current tags avaiable to user
                let tags: [Identifier] = try Tag.all().flatMap { tag in
                    return try? tag.assertExists()
                }
                
                user.tagsID = tags
            }
        }
        
        if let values = json["tags"]?.array {
            let tagsID: [Identifier] = values.flatMap { dict in
                guard let id = dict["id"]?.string else {
                    return nil
                }

                return Identifier(id)
            }
    
            user.tagsID = tagsID
        }

        user.updatedAt = Date()
        try user.save()

        return try user.makeJSON()
    }
}

extension UserController: EmptyInitializable {}
