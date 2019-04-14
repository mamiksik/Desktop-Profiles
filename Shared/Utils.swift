//
//  Utils.swift
//  Maturitka
//
//  Created by Martin Miksik on 19/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Foundation
import Cocoa
import ShellOut
import RealmSwift

// MARK - Utils

final class Utils {
    
    static var bundleUrl: URL {
        get {
            return Bundle.main.resourceURL!
        }
    }
    
    static var saveDataUrl: URL {
        get {
            return Utils.bundleUrl.appendingPathComponent("Saved Application State/")
        }
    }
    
    static var realmConfiguration: RealmSwift.Realm.Configuration {
        get {
            let config = Realm.Configuration()
            print(config.fileURL as Any)
            return config
        }
    }

    static func runAppleScript(withName: Scripts, parameters: String? = nil){
        let path = Bundle.main.url(forResource: withName.rawValue, withExtension: "scpt")!.path
        
        if parameters == Options.keep.description {
            return
        }
        
        if parameters != nil {
            _ = try? shellOut(to: "osascript \"\(path)\" \(parameters!)")
        } else {
            _ = try? shellOut(to: "osascript \"\(path)\"")
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
    
    static func popUpToOption(_ popUp: NSPopUpButton) -> Options? {
        return Options(rawValue: popUp.indexOfSelectedItem)
    }
        
}
