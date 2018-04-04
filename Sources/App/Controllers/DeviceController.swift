import Vapor
import HTTP

final class DeviceController {
    @discardableResult
    func checkAPIKey(_ request: Request) throws -> Identifier {
        guard let appKey = request.headers["Authorization"] else {
            throw Abort(Status.forbidden, reason: "Missing header 'Authorization' parameter")
        }
        
        let appQuery = try App.makeQuery()
        guard let app = try appQuery.filter("key", appKey).first(), let key = app.id  else {
            throw Abort(Status.unauthorized, reason: "Invalid 'Authorization' Key")
        }
        
        return key
    }
    
    func show(_ request: Request) throws -> ResponseRepresentable {
        try checkAPIKey(request)
        
        guard let vendor = request.parameters["vendor"]?.string else {
            throw Abort(Status.notFound, reason: "Vendor ID is required")
        }

        let query = try Device.makeQuery()
        guard let device = try query.filter("vendor", vendor).first() else {
            throw Abort(Status.notFound, reason: "Vendor ID could be found")
        }
        
        return device
    }
    
    func store(_ request: Request) throws -> ResponseRepresentable {
        let key = try checkAPIKey(request)

        guard let json = request.json else {
            throw Abort.badRequest
        }
        
        guard let identifier = json["identifier"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "Missing 'identifier' parameter")
        }
        
        guard let vendor = json["vendor"]?.string else {
            throw Abort(Status.unprocessableEntity, reason: "Missing 'vendor' parameter")
        }
        
        let test: Bool = json["test"]?.bool ?? false
        let subscribed = json["subscribed"]?.bool ?? false
        
        let os = json["os"]?.string
        let model = json["model"]?.string
        let tags = json["tags"]?.object
        let language = json["language"]?.string
        

        let query = try Device.makeQuery()
        guard let device = try query.filter("vendor", vendor).first() else {
            // New device
            let device = try request.device()
            try device.save()

            return device
        }

        device.identifier = identifier
        device.vendor = vendor
        device.test = test
        device.subscribed = subscribed
        device.os = os
        device.model = model
        device.tags = tags
        device.language = language
        device.appID = key
        device.updatedAt = Date()
        
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
