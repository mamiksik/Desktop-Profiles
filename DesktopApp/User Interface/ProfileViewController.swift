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

class ProfileViewController: NSViewController {

    @IBOutlet weak var sidebar: NSOutlineView!
    var notificationToken: NotificationToken?
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

    @IBAction func showPreferences(_ sender: Any) {
        sidebar.selectRowIndexes([], byExtendingSelection: false)
        NotificationCenter.default.post(Notification.init(name: Notification.Name.ProfileListNotification.profileUnselected, object: nil, userInfo: [:]))
    }
}

extension ProfileViewController: NSOutlineViewDataSource {

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
            sidebar.selectedRow > -1,
            let _ = notification.object as? NSOutlineView
        else {
            return
        }

        let profile = list[sidebar.selectedRow]
        NotificationCenter.default.post(Notification.init(name: Notification.Name.ProfileListNotification.profileSelected, object: profile.id, userInfo: [:]))
    }
}

extension ProfileViewController: NSOutlineViewDelegate {

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
