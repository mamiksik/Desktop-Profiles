import Foundation
import RealmSwift
import Magnet
import ShellOut

// MARK - Realm entity declaration
class Profile: BaseEntity {
    @objc dynamic var name = ""
    @objc dynamic var defaultProfile = false
    @objc dynamic var darkMode : Options = .keep
    @objc dynamic var nightShift : Options = .keep
    @objc dynamic var accentColour : Color = .keep
    @objc dynamic var closeOtherApps : Bool = false
    
    @objc dynamic var shortcutKeyCode : Int = -1
    @objc dynamic var shortcutModifierCode : Int = -1
    
    let apps = List<App>()
    let workflows = List<Workflow>()
    
    var keyCombo: KeyCombo? {
        get {
            if let keyCom = KeyCombo(keyCode: shortcutKeyCode, carbonModifiers: shortcutModifierCode) {
                return keyCom
            } else {
                return nil
            }
        }
        set(newKeyCombo) {
            if newKeyCombo != nil {
                shortcutKeyCode = newKeyCombo!.keyCode
                shortcutModifierCode = newKeyCombo!.modifiers
            } else {
                shortcutKeyCode = -1
                shortcutModifierCode = -1
            }
        }
    }
}

// MARK - Comperable
extension Profile {
    static func ==(lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }
}


//MARK - Custom Profile methods
extension Profile {
    
    func copy<T: Sequence>(apps: T) where T.Element == App{
        let fileQueue = DispatchQueue(label: CustomQueue.files.rawValue)
        for app in self.apps {
            try! app.data.copy()
        }
    }
    
    func restoreSettings(){
        let scriptQueue = DispatchQueue(label: CustomQueue.appleScript.rawValue)
        
        // Copy properties to be used in another thread
        let nightShift = self.nightShift
        let darkMode = self.darkMode
        let accentColour = self.accentColour
        
        if ( nightShift     != .keep ||
            darkMode       != .keep ||
            accentColour   != .keep ) {
            scriptQueue.async {
                Utils.runAppleScript(withName: .OpenPreferences)
                Utils.runAppleScript(withName: .NightShift, parameters: nightShift.description)
                Utils.runAppleScript(withName: .DarkMode, parameters: darkMode.description)
                Utils.runAppleScript(withName: .AccentColour, parameters: accentColour.description)
                Utils.runAppleScript(withName: .QuitPreferences)
            }
        }
        
        if self.closeOtherApps {
            Utils.runAppleScript(withName: .KillRunningApplications)
        }
    }
    
    func restore<T: Sequence>(workflows: T) where T.Element == Workflow {
        let scriptQueue = DispatchQueue(label: CustomQueue.appleScript.rawValue)        
        for workflow in workflows {
            let path = workflow.path.replacingOccurrences(of: " ", with: "\\ ")
            scriptQueue.async {
                try! shellOut(to: "/usr/bin/automator", arguments: [path])
            }
        }
    }
    
    func restore<T: Sequence>(apps: T) where T.Element == App {
        for app in apps {
            try? app.data.restore()
        }
    }
    
    func restoreAll(){
        restoreSettings()
        restore(workflows: self.workflows)
        restore(apps: self.apps)
    }
    
}
