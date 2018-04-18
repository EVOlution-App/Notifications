import Vapor

struct OneSignal {
    enum OS: Int, RawRepresentable {
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
    }

    enum TestType: Int {
        case development = 1
        case adHoc = 2
    }

    struct Device {
        let appID: String
        let identifier: String
        let language: String
        let platform: OS
        let deviceOS: String
        let deviceModel: String
        let appVersion: String
        let testType: TestType

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
}

extension OneSignal.Device: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        let keys = OneSignal.Device.Keys.self
        
        try node.set(keys.appID, appID)
        try node.set(keys.identifier, identifier)
        try node.set(keys.language, language)
        try node.set(keys.platform, platform)
        try node.set(keys.deviceOS, deviceOS)
        try node.set(keys.deviceModel, deviceModel)
        try node.set(keys.appVersion, appVersion)
        try node.set(keys.testType, testType)
        
        return node
    }
}
