//
//  PreferenceViewController.swift
//  DesktopProfiles
//
//  Created by Martin Miksik on 13/04/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Cocoa
import KeyHolder
import RealmSwift

class PreferenceViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var darkMode: NSPopUpButton!
    @IBOutlet weak var nightShift: NSPopUpButton!
    @IBOutlet weak var accentColour: NSPopUpButton!
    @IBOutlet weak var closeCheckbox: NSButton!
    @IBOutlet weak var shortcut: RecordView!

    var profile: Profile?
    
    deinit {
        print("PreferenceViewController deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
    }

    override func viewWillAppear() {
        profile = (self.parent as? ProfileSplitViewController)?.profile

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
        
        // RecordView bug - action can not be assign from IB
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

extension PreferenceViewController: NSTextFieldDelegate {
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
