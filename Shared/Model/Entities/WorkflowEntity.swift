import Foundation
import RealmSwift

final class Workflow: Object, NameProtocol {
    @objc dynamic var name = ""
    @objc dynamic var path = ""
}
