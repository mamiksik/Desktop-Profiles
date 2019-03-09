//
//  Utils.swift
//  Maturitka
//
//  Created by Martin Miksik on 19/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import ShellOut

// MARK - Utils

final class Utils {
    
    static let bundleUrl: URL = Bundle.main.bundleURL //FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "com.mamiksik.DesktopProfiles")!
    static let saveDataUrl: URL = Utils.bundleUrl.appendingPathComponent("Saved Application State/")
    
    static var realmConfiguration: RealmSwift.Realm.Configuration {
        get {
            var config = Realm.Configuration()
            config.fileURL = bundleUrl.appendingPathComponent("default.realm")
            return config
        }
    }

    static func runAppleScript(withName: Scripts, parameters: String? = nil){
        let path = Bundle.main.url(forResource: withName.rawValue, withExtension: "scpt")!.path
//        print(path)
        
        if parameters == Options.keep.description {
            return
        }
        
        if parameters != nil {
            let result = try? shellOut(to: "osascript \"\(path)\" \(parameters!)")
//            print(result)
        } else {
            let result = try? shellOut(to: "osascript \"\(path)\"")
//            print(result)
        }
    }
    
    static func confirmationDialog(question: String, text: String, window: NSWindow, completionHandler handler: @escaping ((NSApplication.ModalResponse) -> Void)) {
        
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "dialog.ok".localized)
        alert.addButton(withTitle: "dialog.cancel".localized)
        
        alert.beginSheetModal(for: window, completionHandler: handler)
    }
        
}
