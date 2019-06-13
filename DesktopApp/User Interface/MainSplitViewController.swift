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

enum SplitViews: Int, CaseIterable {
    case profiles, actions, preferences, runnable, events
}

extension Array {
    subscript(index: SplitViews) -> Element {
        return self[index.rawValue]
    }
}

class InvisibleDividerNSSplitView: NSSplitView {
    override var dividerThickness: CGFloat {
            return 0.0
    }
}

class MainSplitViewController: NSSplitViewController {

    let realm: Realm? = try? Realm()
    var item: Name?
    var profileID: String?
    var splitViews: [NSView] {
        return splitView.subviews
    }

    var profile: Profile? {
        if profileID == nil {
            return nil
        }
        return realm?.object(ofType: Profile.self, forPrimaryKey: profileID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setProfile),
            name: Notification.Name.ProfileListNotification.profileSelected,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unsetProfile),
            name: Notification.Name.ProfileListNotification.profileUnselected,
            object: nil
        )

        updateView(nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ProfileSplitViewController deinitialized")
    }

    @objc func setProfile(_ notification: Notification) {
        guard
            let id = notification.object as? String,
            let _ = realm?.object(ofType: Profile.self, forPrimaryKey: id)
        else {
            return
        }

        if id != profileID {
            updateView(id)
        }
    }

    @objc func unsetProfile(_ notification: Notification) {
        updateView(nil)
    }

    private func updateView(_ id: String?) {


        for view in splitViewItems {
            view.isCollapsed = true
        }

        self.profileID = id
        splitViewItems[.profiles].isCollapsed = false

        if profileID != nil {
            splitViewItems[.actions].isCollapsed = false
            splitViewItems[.actions].viewController.updateView()
        }
    }

    func updateSelection(_ item: Name) {

        self.item = item

        for view in SplitViews.preferences.rawValue...SplitViews.events.rawValue {
            splitViewItems[view].isCollapsed = true
        }

        switch item.name {
        case Actions.preferences:
            splitViewItems[.preferences].isCollapsed = false
            splitViewItems[.preferences].viewController.updateView()
        case Actions.events:
            splitViewItems[.events].isCollapsed = false
            splitViewItems[.events].viewController.updateView()
        default:
            splitViews[.runnable].isHidden = false
            splitViewItems[.runnable].isCollapsed = false
            splitViewItems[.runnable].viewController.updateView()
        }
    }
}
