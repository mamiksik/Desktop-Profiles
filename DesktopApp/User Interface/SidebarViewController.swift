import Cocoa
import RealmSwift

class SidebarViewController: NSViewController {

    @IBOutlet weak var sidebar: NSOutlineView!
    var notificationToken: NotificationToken? = nil
    var list: [Profile] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebar.dataSource = self
        sidebar.delegate = self
        
        let realm = try? Realm()
        
        self.list = realm?.objects(Profile.self).toArray() ?? []
        self.sidebar.reloadData()
        
        notificationToken = realm?.observe { [unowned self] _, realm in
            let index = self.sidebar.selectedRow
            self.list = realm.objects(Profile.self).toArray()
            self.sidebar.reloadData()
            
            if index < self.list.count {
                self.selectRow(index)
            } else {
                self.selectRow(index-1)
            }
        }
    }
    
    deinit {
        print("deini")
        NotificationCenter.default.removeObserver(self)
        notificationToken?.invalidate()
    }
    
    @IBAction func performAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let profile = Profile()
            
            let suffix = list.count + 1
            profile.name = "Profile \(suffix)"
            
            let realm = try? Realm()
            try? realm?.write {
                realm?.add(profile)
            }
            
            selectRow(suffix-1)
        } else {
            if self.sidebar.selectedRow < 0 {
                return
            }
            
            Utils.confirmationDialog(
                question: "preferences.alert.deleteProfile.question".localized,
                text: "preferences.alert.deleteProfile.text".localized,
                window: self.view.window!,
                completionHandler: { [unowned self] result in
                    if result == NSApplication.ModalResponse.alertSecondButtonReturn {
                        return
                    }
                    
                    guard let realm = try? Realm() else {
                        return
                    }
                    
                    let profile = realm.objects(Profile.self)[self.sidebar.selectedRow]
                    try? realm.write {
                        realm.delete(profile)
                    }
            })
        }
    }
    
    private func selectRow(_ index: Int) {
        sidebar.selectRowIndexes([index], byExtendingSelection: false)
    }
}

extension SidebarViewController: NSOutlineViewDataSource {

    // Number of items in the sidebar
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        return items.count
        return list.count
    }

    // Items to be added to sidebar
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return list[index]
    }

    // Whether rows are expandable by an arrow
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    // When a row is selected
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard
            let _ = notification.object as? NSOutlineView
        else {
            return
        }
        
        let profile = list[self.sidebar.selectedRow]
        NotificationCenter.default.post(Notification.init(name: Notification.Name.ProfileListNotification.profileSelected, object: profile.id, userInfo: [:]))
    }
}

extension SidebarViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?

        if let profile = item as? Profile {
            
            view = outlineView.makeView(withIdentifier: .name, owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = profile.name
                textField.sizeToFit()
            }
        }

        return view
    }

}
