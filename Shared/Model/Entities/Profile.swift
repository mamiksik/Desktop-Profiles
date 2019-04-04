import Foundation
import Magnet
import ShellOut
import RealmSwift

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
        for app in self.apps {
            try! app.stateData.copy()
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
        for workflow in workflows {
            try? workflow.run()
        }
    }
    
    func restore<T: Sequence>(apps: T) where T.Element == App {
        for app in apps {
            try? app.stateData.restore()
        }
    }
    
    func restoreAll(){
        restoreSettings()
        restore(workflows: self.workflows)
        restore(apps: self.apps)
    }
    
}
