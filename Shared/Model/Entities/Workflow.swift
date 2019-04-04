import Foundation
import ShellOut

final class Workflow: BaseEntity, Runable {
    @objc dynamic var name = ""
    @objc dynamic var path = ""
}

extension Workflow {
    func run() throws {
        let scriptQueue = DispatchQueue(label: CustomQueue.appleScript.rawValue)
        let path = self.path.replacingOccurrences(of: " ", with: "\\ ")
        
        scriptQueue.async {
            try! shellOut(to: "/usr/bin/automator", arguments: [path])
        }
    }
}
