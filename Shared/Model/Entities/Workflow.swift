import Foundation
import RealmSwift

final class Workflow: BaseEntity, Runable {
    @objc dynamic var name = ""
    @objc dynamic var path = ""
}
