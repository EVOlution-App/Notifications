import Vapor

extension OneSignal {
    struct Request {
        static func register(_ device: Device, using drop: Droplet) throws -> OneSignal.Response? {
            let params = try device.makeJSON()
            let request = Vapor.Request(
                method: .post,
                uri: Environment.URL.OneSignal.addDevice,
                headers: ["Content-Type": "application/json"],
                body: params.makeBody()
            )
            
            let response = try drop.client.respond(to: request)
            guard let json = response.json else {
                return nil
            }
            
            guard let result = OneSignal.Response(json) else {
                return nil
            }
            
            return result
        }
    }
}
