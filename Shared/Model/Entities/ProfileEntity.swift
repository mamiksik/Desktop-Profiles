import Foundation
import RealmSwift
import Magnet

class Profile: Object {
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

extension Profile {
    static func ==(lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }
}
