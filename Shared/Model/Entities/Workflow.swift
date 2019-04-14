import Foundation
import ShellOut

final class Workflow: BaseEntity, Runable, ActionItem {
    @objc dynamic var name = ""
    @objc dynamic var path = ""
    
    convenience init(forPath: String, forProfile: Profile) throws {
        let source = URL(fileURLWithPath: forPath)
        let location = Utils.bundleUrl.appendingPathComponent("Workflows/\(forProfile.name)")
        let fm = FileManager.default

        if !fm.fileExists(atPath: location.path) {
            try? fm.createDirectory(at: location, withIntermediateDirectories: true, attributes: [:])
        }
        
        let filePath = location.path + "/\(source.lastPathComponent)"
        try fm.copyItem(atPath: source.path, toPath: filePath)
            
        self.init()
        self.name = source.lastPathComponent
        self.path = filePath
    }
}

extension Workflow {
    func run() throws {
        let scriptQueue = DispatchQueue(label: CustomQueue.appleScript.rawValue)
        let path = self.path.replacingOccurrences(of: " ", with: "\\ ")
        
        scriptQueue.async {
            _ = try? shellOut(to: "/usr/bin/automator", arguments: [path])
        }
    }
}
