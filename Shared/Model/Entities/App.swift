import Foundation
import ShellOut
import Cocoa
import RealmSwift

// MARK - Realm entity declaration
final class App: BaseEntity, Runable, ActionItem {
    @objc dynamic var name = ""
    @objc dynamic var bundleIdentifier = ""
    @objc dynamic var path = ""
    
    let windows = List<Window>()
    
    //Not working with detached – Realm bug
    let profiles = LinkingObjects(fromType: Profile.self, property: "apps")
    
    var profile: Profile {
        return profiles.first!
    }
    
    convenience init(forPath: String) throws {
        guard let bundle = Bundle(path: forPath) else {
            throw AppError.cantGetAppBundle
        }
        
        guard let name = bundle.infoDictionary![kCFBundleNameKey as String] as? String else {
            throw AppError.cantGetAppName
        }
        
        self.init()
        self.name = name
        self.bundleIdentifier = bundle.bundleIdentifier!
        self.path = forPath
    }
    
}


// MARK - Comperable
extension App {
    static func ==(lhs: App, rhs: App) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK - Custom methods
extension App {
    
    var isSanboxed: Bool {
        return Bundle(path: path)?.ob_isSandboxed() ?? false
    }

    var stateData: CustomApplicationStateData {
        switch bundleIdentifier {
        case AppSpecificBehaviour.chrome.rawValue:
            return ChromeStateData(self)
        default:
            if isSanboxed {
                return SanboxedStateData(self)
            } else {
                return DefaultStateData(self)
            }
        }
    }
    
    func close() throws {
        if var pid = try? shellOut(to: "pgrep \(self.name)") {
            if self.bundleIdentifier != AppSpecificBehaviour.chrome.rawValue {
                pid = pid.replacingOccurrences(of: "\n", with: " ")
            }
            try shellOut(to: "kill \(pid)")
        }
    }
    
    func open() throws {
        if AppSpecificBehaviour.finder.rawValue != bundleIdentifier {
            try shellOut(to: "open -b \(self.bundleIdentifier)")
        }
    }
}
