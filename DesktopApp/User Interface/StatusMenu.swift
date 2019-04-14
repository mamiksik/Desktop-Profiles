//
//  MainMenu.swift
//  Maturitka
//
//  Created by Martin Miksik on 19/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Cocoa
import Magnet
import RealmSwift

class StatusMenu: NSObject, NSWindowDelegate {

    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    var preferencesWindow : NSWindowController?
    var notificationToken: NotificationToken?
    var statusMenuOriginalMenu: [NSMenuItem]?
    
    override func awakeFromNib() {
        let icon = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        statusItem.button!.image = icon
        statusItem.menu = statusMenu
        statusMenuOriginalMenu = statusMenu.items
        constructMenu()
        
        guard
            let realm = try? Realm()
        else {
            return
        }
        
        notificationToken = realm.observe { [unowned self] _, _ in
            self.constructMenu()
        }

        #if DEBUG
//        instanceService = InstanceService()
//        instanceService?.delegate = self
        #endif
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func constructMenu() {
        guard let realm = try? Realm() else {
            return
        }
        
        HotKeyCenter.shared.unregisterAll()
        
        statusMenu.removeAllItems()
        statusMenu.items  = statusMenuOriginalMenu!
        statusMenu.addItem(NSMenuItem.separator())

        for row in realm.objects(Profile.self).reversed() {
            let profile = row.detached()
            
            let profItem = NSMenuItem(
                title: profile.name,
                action: #selector(self.restoreFromProfile(_:)),
                keyEquivalent: ""
            )
            
            profItem.target = self

            if profile.keyCombo != nil {
                let hotKey = HotKey(
                    identifier: profile.name,
                    keyCombo: profile.keyCombo!,
                    target: self,
                    action: #selector(self.restoreFromProfileHotKey(_:))
                )
                hotKey.register()

                profItem.keyEquivalentModifierMask = profile.keyCombo!.cocoaFlags
                profItem.keyEquivalent = profile.keyCombo!.characters
            }
            statusMenu.addItem(profItem)
        }
        statusMenu.items.reverse()
    }

    @IBAction func openPreferences(_ sender: Any) {
        if preferencesWindow == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            
            preferencesWindow = storyboard.instantiateController(
                    withIdentifier: "viewController"
                ) as? NSWindowController
        }
        
        preferencesWindow!.showWindow(nil)

        preferencesWindow!.window?.center()
        preferencesWindow!.window?.makeKeyAndOrderFront(nil)
        preferencesWindow!.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: Saves memory
    func windowWillClose(_ notification: Notification) {
        preferencesWindow = nil
    }

    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    @objc func restoreFromProfile(_ sender: NSMenuItem) {
        restore(sender.title)
    }

    // MARK: Fix Magnet can not call objc method on instance variable - that is probably an bug in Magnet library
    @objc func restoreFromProfileHotKey(_ sender: Any) {
        guard let hotKey = sender as? HotKey else { return }
        restore(hotKey.identifier)
    }

    func restore(_ profileName: String) {
        guard
            let realm = try? Realm(),
            let profile = realm.objects(Profile.self).filter("name = %@", profileName).first
        else {
            return
        }

        profile.restoreAll()
    }
}
//
//extension StatusMenu : InstanceServiceDelegate {
//
//    func connectedDevicesChanged(manager: InstanceService, connectedDevices: [String]) {
//        OperationQueue.main.addOperation {
//            print("Connections: \(connectedDevices)")
//        }
//    }
//
//    func profileChanged(manager: InstanceService, profileName: String) {
//        OperationQueue.main.addOperation {
//            self.restore(profileName)
//            NSLog("%@", "Value received: \(profileName)")
//        }
//    }
//}
