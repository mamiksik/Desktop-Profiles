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

class RunableController: NSViewController {

    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var savaStateButton: NSButton!

    var app: App?
    var workflow: Workflow?

    deinit {
        print("RunableController deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        guard
            let parent = self.parent as? MainSplitViewController,
            let item = parent.item as? BaseEntity,
            let realm = try? Realm()
        else {
            return
        }

        if let app = realm.object(ofType: App.self, forPrimaryKey: item.id) {
            self.workflow = nil
            self.app = app
            savaStateButton.isEnabled = true

            icon.image = NSWorkspace.shared.icon(forFile: app.path)
            titleLabel.stringValue = app.name
        } else if let workflow = realm.object(ofType: Workflow.self, forPrimaryKey: item.id) {
            self.app = nil
            savaStateButton.isEnabled = false
            self.workflow = workflow

            icon.image = NSImage(named: NSImage.advancedName)
            titleLabel.stringValue = workflow.name
        }
    }

    @IBAction func saveState(_ sender: Any) {
        if app != nil {
            try? app?.stateData.copy()
        }
    }

    @IBAction func restoreState(_ sender: Any) {
        if app != nil {
            try? app?.stateData.restore()
        }

        if workflow != nil {
            try? workflow?.run()
        }
    }
}
