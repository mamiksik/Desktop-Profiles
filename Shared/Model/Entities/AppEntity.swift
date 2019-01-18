import Foundation
import RealmSwift

final class App: Object, NameProtocol {
    @objc dynamic var name = ""
    @objc dynamic var bundleIdentifier = ""
    
    let windows = List<Window>()
    let profiles = LinkingObjects(fromType: Profile.self, property: "apps")
    
    var profile: Profile {
        return profiles.first!
    }
}

extension App {
    static func ==(lhs: App, rhs: App) -> Bool {
        return lhs.name == rhs.name
    }
}
