////
////  ViewController.swift
////  Maturitka
////
////  Created by Martin Miksik on 12/12/2018.
////  Copyright © 2018 Martin Miksik. All rights reserved.
////
//
//import Cocoa
//import RealmSwift
//
//class ViewController: NSViewController {
//
//    @IBOutlet weak var profilesList: NSPopUpButton!
//    @IBOutlet weak var restoreAppState: NSButton!
//    @IBOutlet weak var closeOthersApps: NSButton!
//
//    @IBOutlet weak var restoreButton: NSButton!
//    @IBOutlet weak var saveButton: NSButton!
//
//
//    @IBOutlet weak var openAppsTable: NSTableView!
//
//    let appManager = ApplicationManager()
//    let modelManager = ModelManager()
//    let realm = try! Realm()
////    let data: Data = Data.sharedInstance
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.window?.title = "Maturitka"
//
//        self.openAppsTable.delegate = self as? NSTableViewDelegate
//        self.openAppsTable.dataSource = self
//
//        DispatchQueue.main.async {
//            self.updateProfiles()
//            self.openAppsTable.reloadData()
//        }
//    }
//
//    @IBAction func addProfile(_ sender: Any) {
//        let profile = Profile()
//        profile.name = "Profile \(realm.objects(Profile.self).count + 1)"
//        try! realm.write {
//            realm.add(profile)
//        }
//        DispatchQueue.main.async {
//            self.updateProfiles()
//            self.updateProfiles(name: profile.name)
//        }
//    }
//
//    @IBAction func deleteProfile(_ sender: Any) {
//        let profiles = realm.objects(Profile.self).filter("name = '\(profilesList.selectedItem!.title)'")
//        try! realm.write {
//            realm.delete(profiles.first!)
//        }
//        DispatchQueue.main.async {
//            self.updateProfiles()
//        }
//    }
//
//    @IBAction func restoreProfile(_ sender: Any) {
//        self.toggleButtons()
//        DispatchQueue.main.async {
//            self.mc.closeApps(forProfile: self.currentProfile())
//
//            let profile = self.modelManager.getBy(profileName: self.currentProfile())
//            let savedApps = profile?.apps
//
//            for app in savedApps! {
//                StateManager.restoreState(forAppBundle: app.bundleIdentifier, forProfile: self.currentProfile())
//            }
//
//            self.mc.openApps(forProfile: self.currentProfile())
//            self.toggleButtons()
//        }
//    }
//
//    @IBAction func saveCurrentState(_ sender: Any) {
//        self.toggleButtons()
//        DispatchQueue.main.async {
//            self.mc.closeApps(forProfile: self.currentProfile())
//
//            let profile = self.modelManager.getBy(profileName: self.currentProfile())
//            let savedApps = profile?.apps
//
//            for app in savedApps! {
//                StateManager.copyState(forAppBundle: app.bundleIdentifier, forProfile: self.currentProfile())
//            }
//
//            self.mc.openApps(forProfile: self.currentProfile())
//            self.toggleButtons()
//        }
//    }
//
//    @IBAction func changed(_ sender: Any) {
//        DispatchQueue.main.async {
//            self.openAppsTable.reloadData()
//        }
//    }
//
//    func updateProfiles(name: String? = nil){
//        profilesList.removeAllItems()
//
//        let profiles = realm.objects(Profile.self)
//        for profile in profiles {
//            profilesList.addItem(withTitle: profile.name)
//        }
//
//        if name != nil {
//            profilesList.selectItem(withTitle: name!)
//        }
//    }
//
//    @IBAction func triggerAppToProfile(_ sender: NSButton) {
//        guard let profile = modelManager.getBy(profileName: currentProfile()) else {
//            return
//        }
//        let row = openAppsTable.row(for: sender)
//        let apps = Utils.getApplications()
//        print(apps.count)
//
//        if apps.count <= row {
//            return
//        }
//
//        let item = apps[row]
//
//        do {
//            if let app = modelManager.getApp(withName: item.name, forProfile: profile) {
//                StateManager.cleanState(forAppBundle: app.bundleIdentifier, forProfile: profile.name)
//                if let index = profile.apps.firstIndex(where: { $0.name == app.name }) {
//                    try realm.write {
//                        profile.apps.remove(at: index)
//                        realm.delete(app)
//                    }
//                }
//            } else {
//                try realm.write {
//                    profile.apps.append(item.toApp())
//                }
//            }
//        } catch let e {
//            print(e)
//        }
//    }
//
//    @IBAction func saveWindowState(_ sender: Any) {
//        mc.saveWindowsSatate(forProfile: currentProfile())
//    }
//
//    func currentProfile() -> String {
//        guard let selectedItem = profilesList.selectedItem else {
//            return ""
//        }
//
//        return selectedItem.title
//    }
//
//    func toggleButtons() {
//        restoreButton.isEnabled = !restoreButton.isEnabled
//        saveButton.isEnabled = !saveButton.isEnabled
//    }
//}
//
//
//extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
//
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return Utils.getApplications().count
//    }
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//
//        let  apps = Utils.getApplications()
//
//        if apps.count < (row - 1) {
//            return nil
//        }
//
//        let item = apps[row]
//
//        if tableColumn?.identifier == NSUserInterfaceItemIdentifier.name {
//            let view = tableView.makeView(withIdentifier: .name, owner: self) as? NSTableCellView
//            view?.textField?.stringValue = item.name
//            return view
//        } else {
//            let view = tableView.makeView(withIdentifier: .check, owner: self) as! NSButton
//
//            guard let profile = modelManager.getBy(profileName: currentProfile()) else {
//                return view
//            }
//
//            if (modelManager.getApp(withName: item.name, forProfile: profile) != nil) {
//                view.state = NSControl.StateValue.on
//            } else {
//                view.state = NSControl.StateValue.off
//            }
//
//            return view
//        }
//    }
//}
