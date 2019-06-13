/* Copyright (C) Martin Miksik 2019

   This file is part of Desktop Profile

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Cocoa
import KeyHolder
import RealmSwift

class ProfilePreferencesController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var darkMode: NSPopUpButton!
    @IBOutlet weak var nightShift: NSPopUpButton!
    @IBOutlet weak var accentColour: NSPopUpButton!
    @IBOutlet weak var closeCheckbox: NSButton!
    @IBOutlet weak var shortcut: RecordView!

    var profile: Profile?

    deinit {
        print("ProfilePreferencesController deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
    }

    override func updateView() {
        profile = (self.parent as? MainSplitViewController)?.profile

        if profile != nil {
            name.stringValue = profile!.name
            darkMode.selectItem(at: profile!.darkMode.rawValue)
            nightShift.selectItem(at: profile!.nightShift.rawValue)
            accentColour.selectItem(at: profile!.accentColour.rawValue)
            shortcut.keyCombo = profile!.keyCombo

            if profile!.closeOtherApps {
                closeCheckbox.state = .on
            } else {
                closeCheckbox.state = .off
            }
        }

//         RecordView bug - action can not be assign from IB
        shortcut.didChange = { keyCombo in
            self.valueChanged(self.shortcut as Any)
        }
    }

    @IBAction func valueChanged(_ sender: Any) {
        guard let realm = try? Realm() else {
            return
        }

        do {
            if let value = Utils.popUpToOption(darkMode!) {
                try realm.write {
                    profile!.darkMode = value
                }
            }

            if let value = Utils.popUpToOption(nightShift!) {
                try realm.write {
                    profile!.nightShift = value
                }
            }

            if let value = Color(rawValue: accentColour!.indexOfSelectedItem) {
                try realm.write {
                    profile!.accentColour = value
                }
            }

            try realm.write {
                if closeCheckbox.state == .off {
                    profile!.closeOtherApps = false
                } else {
                    profile!.closeOtherApps = true
                }
            }

            try realm.write {
                profile!.keyCombo = shortcut.keyCombo
            }

        } catch {
            NSLog(error.localizedDescription)
        }
    }
}

extension ProfilePreferencesController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ notification: Notification) {
        guard
            let textField = notification.object as? NSTextField,
            let profile = self.profile,
            let realm = try? Realm(),
            realm.objects(Profile.self).filter("name = %@", textField.stringValue).count <= 0
        else {
            return
        }

        do {
            let oldName = profile.name
            let oldLocation = Utils.bundleUrl.appendingPathComponent("\(oldName)")
            let newLocation = Utils.bundleUrl.appendingPathComponent("\(textField.stringValue)")

            let fm = FileManager.default
            if fm.fileExists(atPath: oldLocation.path) {
                try fm.moveItem(at: oldLocation, to: newLocation)
            }

            try realm.write {
                profile.name = textField.stringValue
            }

        } catch {
            NSLog(error.localizedDescription)
        }
    }
}
