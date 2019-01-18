import Foundation
import RealmSwift

final class Facade {

    public static let shared = Facade()
    public let realm = try! Realm(configuration: Utils.realmConfiguration)
    
    private let fm = FileManager.default
    
    private init() {}
    
    func getAll<Element: Object>(_ type: Element.Type) -> Results<Element> {
        return realm.objects(type)
    }
    
    func count<Element: Object>(_ type: Element.Type) -> Int {
        return realm.objects(type).count
    }
    
    func getBy(profileName: String) -> Profile? {
        let predicate = NSPredicate(format: "name = '\(profileName)'")
        return realm.objects(Profile.self).filter(predicate).first
    }
    
    func getApp(withName: String, forProfile: Profile) -> App? {
        let predicate = NSPredicate(format: "name = '\(withName)' AND ANY profiles.name = '\(forProfile.name)'")
        return realm.objects(App.self).filter(predicate).first
    }
    
    
    func rename(profile: Profile, newName: String) throws {
        if getBy(profileName: newName) != nil {
            throw ProfileError.profileWithSameNameAlreadyExiest
        }
        
        let oldName = profile.name
        try self.realm.write {
            profile.name = newName
        }
        
        var oldLocation = Utils.bundleUrl.appendingPathComponent("Workflows/\(oldName)")
        var newLocation = Utils.bundleUrl.appendingPathComponent("Workflows/\(newName)")
        if fm.fileExists(atPath: oldLocation.path) {
            try? fm.moveItem(at: oldLocation, to: newLocation)
        }
        
        oldLocation = Utils.bundleUrl.appendingPathComponent("Saved Application State/\(oldName)")
        newLocation = Utils.bundleUrl.appendingPathComponent("Saved Application State/\(newName)")
        if fm.fileExists(atPath: oldLocation.path) {
            try? fm.moveItem(at: oldLocation, to: newLocation)
        }
    }
    
    func addApp(toProfile: Profile, withPath: String) {
        guard let bundle = Bundle(path: withPath) else {
            return
        }
        
        let app = App()
        app.name = bundle.infoDictionary![kCFBundleNameKey as String] as! String
        app.bundleIdentifier = bundle.bundleIdentifier!
        
        try! realm.write {
            toProfile.apps.append(app)
        }
    }
    
    func addWorkflow(toProfile: Profile, withPath: String) {
        let source = URL(fileURLWithPath: withPath)
        let location = Utils.bundleUrl.appendingPathComponent("Workflows/\(toProfile.name)")
        do {
            if !fm.fileExists(atPath: location.path) {
                try! fm.createDirectory(at: location, withIntermediateDirectories: true, attributes: [:])
            }
            let filePath = location.path + "/\(source.lastPathComponent)"
            try self.fm.copyItem(atPath: source.path, toPath: filePath)
            
            let workflow = Workflow()
            workflow.name = source.lastPathComponent
            workflow.path = filePath
            try realm.write {
                toProfile.workflows.append(workflow)
            }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    func remove(workflow: Workflow, fromProfile: Profile)
    {
        do {
            let path = workflow.path
            try realm.write { realm.delete(workflow) }
            if fm.isDeletableFile(atPath: path) { try fm.removeItem(atPath: path) }
        } catch {
            NSLog(error.localizedDescription)
        }
    }
}
