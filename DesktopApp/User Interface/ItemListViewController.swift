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
import RealmSwift

protocol ActionItem {
    var name: String { get }
}

class ActionPreferences: ActionItem {
    var name = "Preferences"
}

extension Notification.Name {
    struct ProfileListNotification {
        static let profileSelected = Notification.Name("profileSelected")
        static let profileUnselected = Notification.Name("profileUnselected")
    }
}

class ItemListViewController: NSViewController {
    
    @IBOutlet weak var sidebar: NSOutlineView!

//    var realm: Realm?
    var profile: Profile?
    var items: [ActionItem] = []
    let dialog = NSOpenPanel()

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebar.dataSource = self
        sidebar.delegate = self
        
        dialog.showsResizeIndicator     = true
        dialog.showsHiddenFiles         = false
        dialog.canChooseDirectories     = false
        dialog.canCreateDirectories     = false
        dialog.allowsMultipleSelection  = false
        dialog.title                    = "dialog.chose.appOrWorkflow".localized
        dialog.allowedFileTypes         = ["app", "workflow"]
        dialog.isReleasedWhenClosed = true
    }
    
    override func viewWillAppear() {
        reloadData()
    }
    
    deinit {
        print("ItemListViewController deinitialized")
    }
    
    @IBAction func restoreProfile (_ sender: Any) {
        profile?.restoreAll()
    }
    
    @IBAction func performAction (_ sender: NSSegmentedControl) {
         if sender.selectedSegment == 0 {
            addRunable()
         } else {
            removeRunable()
        }
    }

    func addRunable () {
        dialog.beginSheetModal(
            for: self.view.window!,
            completionHandler: { [unowned self] result in
                autoreleasepool {
            guard
                result == NSApplication.ModalResponse.OK,
                let path = self.dialog.url?.path,
                let profile = self.profile,
                let realm = try? Realm()
            else {
                return
            }

            do {
                if self.dialog.url!.pathExtension == "app" {
                    let app = try App(forPath: path)
                    try realm.write {
                        profile.apps.append(app)
                    }
                } else if self.dialog.url!.pathExtension == "workflow" {
                    let workflow = try Workflow(forPath: path, forProfile: profile)
                    try realm.write {
                        profile.workflows.append(workflow)
                    }
                }
            } catch {
                NSLog(error.localizedDescription)
            }
            
            self.reloadData()
                }
        })
    }
    
    func removeRunable () {
        let index: Int = sidebar.selectedRow

        // 0 is preferences
        if index != 0 {
            guard
                let detachedObj = items[index] as? BaseEntity,
                let realm = try? Realm()
            else {
                return
            }
            do {
                if let app = realm.object(ofType: App.self, forPrimaryKey: detachedObj.id) {
                    try app.stateData.clean()
                    try realm.write {
                        realm.delete(app)
                    }
                } else if let workflow = realm.object(ofType: Workflow.self, forPrimaryKey: detachedObj.id) {
                    let path = workflow.path
                    let fm = FileManager.default

                    try realm.write {
                        realm.delete(workflow)
                    }

                    if fm.isDeletableFile(atPath: path) {
                        try fm.removeItem(atPath: path)
                    }
                }
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        reloadData()
        sidebar.selectRowIndexes([index - 1], byExtendingSelection: false)
    }

    func reloadData() {
        profile = (self.parent as? ProfileSplitViewController)?.profile

        items = []
        if profile != nil {
            items.append(ActionPreferences())
            items.append(contentsOf: profile!.apps.toArray())
            items.append(contentsOf: profile!.workflows.toArray())
        }

        sidebar.reloadData()
    }
}

extension ItemListViewController: NSOutlineViewDataSource {

    // Number of items in the sidebar
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return items.count
    }

    // Items to be added to sidebar
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return items[index]
    }

    // Whether rows are expandable by an arrow
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    // When a row is selected
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let outlineView = notification.object as? NSOutlineView {
            if outlineView.selectedRow == -1 { return }

            let item = items[outlineView.selectedRow]
            (self.parent as? ProfileSplitViewController)?.updateView(item)
        }
    }

}

extension ItemListViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        if let item = item as? ActionItem {
            if tableColumn?.identifier == .name {
                let cellView = outlineView.makeView(withIdentifier: .name, owner: self) as? NSTableCellView
                if let textField = cellView?.textField {
                    textField.stringValue = item.name
                    textField.sizeToFit()
                }
                return cellView
            } else {
                let cellView = outlineView.makeView(withIdentifier: .icon, owner: self) as? NSTableCellView
                let imageView = cellView?.subviews[0] as? NSImageView
                
                if let app = item as? App {
                    imageView?.image = NSWorkspace.shared.icon(forFile: app.path)
                } else if let _ = item as? Workflow {
                    imageView?.image = NSImage(named: NSImage.advancedName)
                } else {
                    imageView?.image = NSImage(named: NSImage.preferencesGeneralName)
                }
                imageView?.sizeToFit()
                return cellView
            }
        }

        return nil
    }
}
