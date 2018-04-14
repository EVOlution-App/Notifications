import Vapor
import HTTP

final class TagController {
    func list(_ request: Request) throws -> ResponseRepresentable {
        let key = try AuthorizationProvider.checkAPIKey(request)
        
        let query = try Tag.makeQuery()
        guard let tags = try? query.filter("app", key).all() else {
            throw Abort(Status.noContent)
        }
        
        return try tags.makeJSON()
    }
}

extension TagController: EmptyInitializable {}
