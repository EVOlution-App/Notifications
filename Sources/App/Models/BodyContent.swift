import Foundation
import HTTP

struct BodyContent {
    let status: Status
    let reason: String?
    
    init(_ code: Status, reason: String? = nil) {
        self.status = code
        self.reason = reason
    }
}

extension BodyContent: ResponseRepresentable, JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("statusCode", status.statusCode)
        
        if let reason = reason {
            try json.set("reason", reason)
        }
        
        return json
    }
    
    func makeResponse() throws -> Response {
        return try self.makeJSON().makeResponse()
    }
}
