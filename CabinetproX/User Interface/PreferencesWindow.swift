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
    
    var tableData: [NameProtocol] = []

    var facade = Facade.shared
    var state = MMStates()
    
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
//        window!.delegate = self
//        self.profileNameField.delegate = self
        
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
    
    deinit {
        print("deinit")
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
        
        confirmationDialog(question: "preferences.alert.deleteProfile.question".localized, text: "preferences.alert.deleteProfile.text".localized, completionHandler: { (result)  in
            if result == NSApplication.ModalResponse.alertSecondButtonReturn {
                return
            }
            
            try! self.realm.write {
                self.realm.delete(self.selectedProfile!)
            }
            
            self.updateProfileList()
        
        })
    }
    
    @IBAction func saveProfileSettings(_ sender: NSButton) {
        
        // MARK - Update name
        if selectedProfile!.name !=  profileNameField.stringValue {
            do {
                try facade.rename(profile: selectedProfile!, newName: profileNameField.stringValue)
                //profileSelector.selectedItem!.title = selectedProfile!.name
                updateProfileList(name: profileNameField.stringValue)
                NotificationCenter.default.post(name: .realodProfiles, object: nil)
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
        state.restore(fromProfile: selectedProfile!)
    }
    
    @IBAction func saveToProfile(_ sender: NSButton) {
        state.save(toProfile: selectedProfile!)
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
                    facade.addApp(toProfile: selectedProfile!, withPath: path)
                } else {
                    facade.addWorkflow(toProfile: selectedProfile!, withPath: path)
                }
                
                updateTable(tableSegmentControl)
            } else {
                return
            }
        }
    }
    
    @IBAction func removeItem(_ sender: NSButton) {
        let selectedRow = table.selectedRow
        if selectedRow == -1 {
            return
        }
        
        if tableSegmentControl.selectedSegment == 0 {
            let app = selectedProfile!.apps[selectedRow]
            try! realm.write {
                selectedProfile!.apps.remove(at: selectedRow)
                realm.delete(app)
            }
        } else {
            let workflow = selectedProfile!.workflows[selectedRow]
            facade.remove(workflow: workflow, fromProfile: selectedProfile!)
        }
        updateTable(tableSegmentControl)
    }
    
    @IBAction func updateTable(_ sender: NSSegmentedControl) {
        print(sender.selectedSegment)
        
        if sender.selectedSegment == 0 {
            tableData = Array((selectedProfile?.apps)!) as [NameProtocol]
        } else {
            tableData = Array((selectedProfile?.workflows)!) as [NameProtocol]
        }
        
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    
    // MARK - Methods
    
    func confirmationDialog(question: String, text: String, completionHandler handler: @escaping ((NSApplication.ModalResponse) -> Void)) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "dialog.ok".localized)
        alert.addButton(withTitle: "dialog.cancel".localized)
        
        alert.beginSheetModal(for: window!, completionHandler: handler)
    }
    
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
        NotificationCenter.default.post(name: .realodProfiles, object: nil)
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
            
            guard let file = NSWorkspace.shared.fullPath(forApplication: item.name) else {
                view.image = NSImage(named: NSImage.folderSmartName)
                return view
            }
            
            view.image = NSWorkspace.shared.icon(forFile: file)
            return view
        }
    }
}
