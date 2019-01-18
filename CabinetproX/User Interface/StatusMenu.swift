//
//  MainMenu.swift
//  Maturitka
//
//  Created by Martin Miksik on 19/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Cocoa
import RealmSwift
import Magnet

class StatusMenu: NSObject, NSWindowDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let states = MMStates()
    var preferencesWindow : PreferencesWindow? = nil
    
    @IBOutlet weak var statusMenu: NSMenu!
    var statusMenuOriginalMenu: [NSMenuItem]?
    
    override func awakeFromNib() {
        let icon = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        statusItem.button!.image = icon
        statusItem.menu = statusMenu
        statusMenuOriginalMenu = statusMenu.items
        constructMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(realodProfiles(notfication:)), name: .realodProfiles, object: nil)
        
    }
    
    func constructMenu() {
        
        let realm = Facade.shared.realm
        HotKeyCenter.shared.unregisterAll()
        
        statusMenu.removeAllItems()
        statusMenu.items  = statusMenuOriginalMenu!
        statusMenu.addItem(NSMenuItem.separator())
        
        for profile in realm.objects(Profile.self).reversed() {
            let profItem = NSMenuItem(title: profile.name, action: #selector(states.restoreFromProfile(_:)), keyEquivalent: "")
            profItem.target = states.self

            if profile.keyCombo != nil {
                let hotKey = HotKey(identifier: profile.name, keyCombo: profile.keyCombo!, target: self, action: #selector(self.restoreFromProfileHotKey(_:)))
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
            preferencesWindow = PreferencesWindow()
        }
        preferencesWindow!.showWindow(nil)
        
        preferencesWindow!.window?.center()
        preferencesWindow!.window?.makeKeyAndOrderFront(nil)
        preferencesWindow!.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    
    //MARK - Saves memory
    func windowWillClose(_ notification: Notification) {
        preferencesWindow = nil
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func realodProfiles(notfication: NSNotification) {
        constructMenu()
    }
    
    // MARK - Fix Magnet can not call objc method on instance variable - that is bug in Magnet library
    @objc func restoreFromProfileHotKey(_ sender: Any) {
        states.restoreFromProfileHotKey(sender)
    }
}

extension MMStates {
    @objc func saveToProfile(_ sender: NSMenuItem) {
        let facade = Facade.shared
        let profile = facade.getBy(profileName: sender.title)
        save(toProfile: profile!)
    }
    
    @objc func restoreFromProfile(_ sender: NSMenuItem) {
        let facade = Facade.shared
        let profile = facade.getBy(profileName: sender.title)
        restore(fromProfile: profile!)
    }
    
    @objc func restoreFromProfileHotKey(_ sender: Any) {
        guard let hotKey = sender as? HotKey else { return }
        let facade = Facade.shared
        let profile = facade.getBy(profileName: hotKey.identifier)
        restore(fromProfile: profile!)
    }
}
