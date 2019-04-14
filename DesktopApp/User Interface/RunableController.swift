//
//  RunableController.swift
//  DesktopProfiles
//
//  Created by Martin Miksik on 13/04/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Cocoa
import RealmSwift

class RunableController: NSViewController {
    
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var savaStateButton: NSButton!
    
    var app: App? = nil
    var workflow: Workflow? = nil
    
    deinit {
        print("RunableController deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        guard
            let parent = self.parent as? ProfileSplitViewController,
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
