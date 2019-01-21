//
//  PreferencesWindow.swift
//  Maturitka
//
//  Created by Martin Miksik on 19/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Cocoa
import RealmSwift
import KeyHolder

class PreferencesWindow: NSWindowController {
    
    // MARK - Outlets
    
    @IBOutlet weak var profileSelector: NSPopUpButton!
    @IBOutlet weak var addProfile: NSButton!
    @IBOutlet weak var deleteProfile: NSButton!
    
    @IBOutlet weak var profileNameField: NSTextField!
    @IBOutlet weak var darkModeSelector: NSPopUpButton!
    @IBOutlet weak var nightShiftSelector: NSPopUpButton!
    @IBOutlet weak var accentColourSelector: NSPopUpButton!
    @IBOutlet weak var closeOtherAppsCheckbox: NSButton!
    @IBOutlet weak var recordView: RecordView!
    
    @IBOutlet weak var loadFromProfile: NSButton!
    @IBOutlet weak var saveToProfile: NSButton!
    
    @IBOutlet weak var tableSegmentControl: NSSegmentedControl!
    @IBOutlet weak var table: NSTableView!
    
    // MARK - Variables
    
    var tableData: [Runable] = []

    var facade = Facade.shared
    
    lazy var realm = Facade.shared.realm
    
    var selectedProfile: Profile? {
        get {
            guard let profileName = profileSelector.selectedItem?.title else {
                return nil
            }
            
            guard let profile = facade.getBy(profileName: profileName) else {
                return nil
            }
            
            return profile
        }
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }

    // MARK - windowDid... methods
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.table.delegate = self
        self.table.dataSource = self
       
        self.updateProfileList()
        
        if selectedProfile == nil  {
            let profile = Profile()
            profile.name = "Default profile"
            try! self.realm.write {
                self.realm.add(profile)
            }
            
            self.updateProfileList()
        }
    }
    
    // MARK - Actions
    // MARK - Profile controls
    
    @IBAction func addProfile(_ sender: NSButton) {
        let profile = Profile()
        profile.name = "Profile \(realm.objects(Profile.self).count + 1)"
        
        try? realm.write {
            realm.add(profile)
        }
        
        self.updateProfileList(name: profile.name)
    }
    
    @IBAction func deleteProfile(_ sender: NSButton) {
        Utils.confirmationDialog(question: "preferences.alert.deleteProfile.question".localized, text: "preferences.alert.deleteProfile.text".localized, window: self.window!, completionHandler: { (result)  in
            if result == NSApplication.ModalResponse.alertSecondButtonReturn { return }
            try! self.realm.write { self.realm.delete(self.selectedProfile!) }
            self.updateProfileList()
        })
    }
    
    @IBAction func saveProfileSettings(_ sender: NSButton) {
        
        // MARK - Update name
        if selectedProfile!.name !=  profileNameField.stringValue {
            do {
                try facade.rename(profile: selectedProfile!, newName: profileNameField.stringValue)
                updateProfileList(name: profileNameField.stringValue)
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        
        // MARK - Update preferences
        if let darkMode = Options(rawValue: darkModeSelector!.indexOfSelectedItem) {
            try! realm.write {
                selectedProfile!.darkMode = darkMode
            }
        }
        
        if let accentColour = Color(rawValue: accentColourSelector!.indexOfSelectedItem) {
            try! realm.write {
                selectedProfile!.accentColour = accentColour
            }
        }
        
        if let nightShift = Options(rawValue: nightShiftSelector!.indexOfSelectedItem) {
            try! realm.write {
                selectedProfile!.nightShift = nightShift
            }
        }
        
        try! realm.write {
            if closeOtherAppsCheckbox.state == .off {
                selectedProfile!.closeOtherApps = false
            } else {
                selectedProfile!.closeOtherApps = true
            }
        }
        
        try! realm.write {
            selectedProfile!.keyCombo = recordView.keyCombo
        }
    }
    
    @IBAction func selectedProfileChanged(_ sender: NSPopUpButton) {
        profileNameField.stringValue = selectedProfile!.name
        darkModeSelector.selectItem(at: selectedProfile!.darkMode.rawValue)
        accentColourSelector.selectItem(at: selectedProfile!.accentColour.rawValue)
        nightShiftSelector.selectItem(at: selectedProfile!.nightShift.rawValue)
        
        recordView.keyCombo = selectedProfile!.keyCombo
        
        if selectedProfile!.closeOtherApps {
            closeOtherAppsCheckbox.state = .on;
        } else {
            closeOtherAppsCheckbox.state = .off;
        }
        
        
        tableSegmentControl.selectSegment(withTag: 0)
        updateTable(tableSegmentControl)
    }

    
    // MARK - Profile state saving and loading
    
    @IBAction func loadFromProfile(_ sender: NSButton) {
        selectedProfile?.restoreAll()
    }
    
    @IBAction func loadSelectedFromProfile(_ sender: NSButton) {
        let selectedRows = table.selectedRowIndexes
        for index in selectedRows {
            let app = selectedProfile!.apps[index]
            try? app.data.restore()
        }
    }
    
    @IBAction func saveToProfile(_ sender: NSButton) {
        selectedProfile?.copy(apps: self.selectedProfile!.apps)
    }
    
    @IBAction func saveSelectedToProfile(_ sender: NSButton) {
        let selectedRows = table.selectedRowIndexes
        for index in selectedRows {
            let app = selectedProfile!.apps[index]
            try? app.data.copy()
        }
    }
    
    // MARK - Table control
    
    @IBAction func addItem(_ sender: NSButton) {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator     = true;
        dialog.showsHiddenFiles         = false;
        dialog.canChooseDirectories     = false;
        dialog.canCreateDirectories     = false;
        dialog.allowsMultipleSelection  = false;

        if tableSegmentControl.selectedSegment == 0 {
            dialog.title            = "dialog.chose.app".localized;
            dialog.allowedFileTypes = ["app"];
        } else {
            dialog.title            = "dialog.chose.workflow".localized;
            dialog.allowedFileTypes = ["workflow"];
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let path = dialog.url?.path {
                if tableSegmentControl.selectedSegment == 0 {
                    do {
                        try facade.addApp(toProfile: selectedProfile!, withPath: path)
                    } catch {
                        NSLog(error.localizedDescription)
                    }
                } else {
                    facade.addWorkflow(toProfile: selectedProfile!, withPath: path)
                }
                
                updateTable(tableSegmentControl)
            } else {
                return
            }
        }
    }
    
    @IBAction func removeItems(_ sender: NSButton) {
        let selectedRows = table.selectedRowIndexes
        let isApp = tableSegmentControl.selectedSegment == TableSegmentControl.app.rawValue ? true : false
        
        var entities: [Runable] = []
        for index in selectedRows {
            if isApp {
                entities.append(selectedProfile!.apps[index])
            } else {
                entities.append(selectedProfile!.workflows[index])
            }
        }
        
        if isApp {
            facade.remove(apps: entities as! [App], fromProfile: selectedProfile!)
        } else {
            facade.remove(workflows: entities as! [Workflow], fromProfile: selectedProfile!)
        }
        
        updateTable(tableSegmentControl)
    }
    
    @IBAction func updateTable(_ sender: NSSegmentedControl) {
        print(sender.selectedSegment)
        
        if sender.selectedSegment == 0 {
            tableData = Array((selectedProfile?.apps)!) as [Runable]
        } else {
            tableData = Array((selectedProfile?.workflows)!) as [Runable]
        }
        
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    // MARK - Methods
    
    func updateProfileList(name: String? = nil) {
        profileSelector.removeAllItems()
        let profiles = realm.objects(Profile.self)
        for profile in profiles {
            profileSelector.addItem(withTitle: profile.name)
        }
        
        if name != nil {
            profileSelector.selectItem(withTitle: name!)
        }
        
        if selectedProfile != nil {
            selectedProfileChanged(profileSelector)
        }
    }
}

// MARK - Table delegate

extension PreferencesWindow: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let item = tableData[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier.name {
            let view = tableView.makeView(withIdentifier: .name, owner: self) as! NSTableCellView
            view.textField?.stringValue = item.name
            
            return view
        } else {
            let view = tableView.makeView(withIdentifier: .icon, owner: self) as! NSImageView
            
            if let app = item as? App  {
                view.image = NSWorkspace.shared.icon(forFile: app.path)
            } else {
                view.image = NSImage(named: NSImage.folderSmartName)
            }
            
            return view
        }
    }
}

// MARK - Window segment control
enum TableSegmentControl: Int {
    case app
    case workflow
}
