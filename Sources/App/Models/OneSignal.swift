import Vapor

struct OneSignal {
    public enum OS: Int, RawRepresentable {
        case ios = 0
        case macos = 9
        case safari = 7
        case chrome = 5
        case firefox = 8

        public init?(rawValue: RawValue) {
            switch rawValue {
            case 0: self = .ios
            case 9: self = .macos
            case 7: self = .safari
            case 5: self = .chrome
            case 8: self = .firefox
            default: return nil
            }
        }

        public init?(_ value: String) {
            switch value {
            case "ios": self = .ios
            case "macos": self = .macos
            case "safari": self = .safari
            case "chrome": self = .chrome
            case "firefox": self = .firefox
            default: return nil
            }
        }
        
        public var value: String {
            switch self {
            case .ios: return "ios"
            case .macos: return "macos"
            case .safari: return "safari"
            case .chrome: return "chrome"
            case .firefox: return "firefox"
            }
        }
    }

    enum TestType: Int {
        case development = 1
        case adHoc = 2
    }

    struct Device {
        let appID: String
        let identifier: String
        let language: String?
        let platform: OS?
        let deviceOS: String?
        let deviceModel: String?
        let appVersion: String?
        let testType: TestType?

        struct Keys {
            static var appID        : String = "app_id"
            static let identifier   : String = "identifier"
            static let language     : String = "language"
            static let platform     : String = "device_type"
            static let deviceOS     : String = "device_os"
            static let deviceModel  : String = "device_model"
            static let appVersion   : String = "game_version"
            static let testType     : String = "test_type"
        }
    }
    
    struct Response {
        let id: String
        let success: Bool
        
        init?(_ json: JSON) {
            guard
                let id = json["id"]?.string,
                let success = json["success"]?.bool else {
                return nil
            }
            
            self.id = id
            self.success = success
        }
    }
}

extension OneSignal.Device: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        let keys = OneSignal.Device.Keys.self
        
        try node.set(keys.appID, appID)
        try node.set(keys.identifier, identifier)
        
        if let value = language {
            try node.set(keys.language, value)
        }
        
        if let value = platform {
            try node.set(keys.platform, value.rawValue)
        }
        
        if let value = deviceOS {
            try node.set(keys.deviceOS, value)
        }
        
        if let value = deviceModel {
            try node.set(keys.deviceModel, value)
        }
        
        if let value = appVersion {
            try node.set(keys.appVersion, value)
        }
        
        if let value = testType {
            try node.set(keys.testType, value.rawValue)
        }
        
        return node
    }
    
    func makeJSON() throws -> JSON {
        let node = try makeNode(in: nil)
        let json = JSON(node: node)
        
        return json
    }
}

extension OneSignal.Device {
    static func create(with token: String, using json: JSON) -> OneSignal.Device? {
        guard let appID = Environment.Keys.OneSignal.app else {
            return nil
        }
        
        guard
            let code = json["platform"]?.string,
            let platform = OneSignal.OS(code) else {
                return nil
        }
        
        let language     = json["language"]?.string
        let model        = json["model"]?.string
        let os           = json["os"]?.string
        let appVersion   = json["appVersion"]?.string
        
        var testType: OneSignal.TestType?
        if let value = json["test"]?.bool, value {
            testType = .development
        }

        let device = OneSignal.Device(
            appID: appID,
            identifier: token,
            language: language,
            platform: platform,
            deviceOS: os,
            deviceModel: model,
            appVersion: appVersion,
            testType: testType
        )
        
        return device
    }
}
