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

class ProfileSplitViewController: NSSplitViewController {
    
    let realm: Realm? = try? Realm()

    var listView: NSSplitViewItem?
    var runnableView: NSSplitViewItem?
    var preferencesView: NSSplitViewItem?
    var dummView: NSSplitViewItem?
    var item: ActionItem?
    var profileID: String?
    
    var profile: Profile? {
        if profileID == nil {
            return nil
        }
        return realm?.object(ofType: Profile.self, forPrimaryKey: profileID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listView = self.splitViewItems[0]
        preferencesView = self.splitViewItems[1]
        runnableView = self.splitViewItems[2]
        dummView = self.splitViewItems[3]

        if runnableView != nil {
            self.removeSplitViewItem(preferencesView!)
            self.removeSplitViewItem(runnableView!)
        }

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
            profileID = id
            updateView(nil)
        }
    }

    @objc func unsetProfile(_ notification: Notification) {
        profileID = nil
    }

    func updateView(_ item: ActionItem?) {
        if item == nil {
            listView?.viewController.viewWillAppear()
        }

        removeChild(at: 1)
        self.item = item

        if  item == nil {
            insertSplitViewItem(dummView!, at: 1)
        } else if  item!.name == "Preferences"{
            insertSplitViewItem(preferencesView!, at: 1)
        } else {
            insertSplitViewItem(runnableView!, at: 1)
            runnableView?.viewController.viewWillAppear()
        }
    }
}
