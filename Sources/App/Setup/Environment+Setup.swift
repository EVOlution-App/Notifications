import Foundation

struct Environment {
    struct Keys {
        struct OneSignal {
            static var restAPI: String? {
                return ProcessInfo.processInfo.environment["ONESIGNAL_RESTAPI_KEY"] ?? nil
            }
            
            static var app: String? {
                return ProcessInfo.processInfo.environment["ONESIGNAL_APP_ID"] ?? nil
            }
        }
    }
    
    struct URL {
        struct OneSignal {
            static var baseURL: String {
                return "https://onesignal.com/api/v1"
            }
            
            static var addDevice: String {
                return baseURL + "/players"
            }
            
            static func update(device id: String) -> String {
                return "\(addDevice)/\(id)"
            }
        }
    }
}
