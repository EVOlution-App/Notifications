import Vapor
import HTTP

final class AuthorizationProvider {
    @discardableResult
    static func checkAPIKey(_ request: Request) throws -> Identifier {
        guard let appKey = request.headers["Authorization"] else {
            throw Abort(Status.forbidden, reason: "Missing header 'Authorization' parameter")
        }
        
        let appQuery = try App.makeQuery()
        guard let app = try appQuery.filter("key", appKey).first(), let key = app.id  else {
            throw Abort(Status.unauthorized, reason: "Invalid 'Authorization' Key")
        }
        
        return key
    }
}
