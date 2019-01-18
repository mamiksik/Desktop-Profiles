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
    
    static var realmConfiguration: RealmSwift.Realm.Configuration {
        get {
            var config = Realm.Configuration()
            config.fileURL = bundleUrl.appendingPathComponent("default.realm")
            return config
        }
    }
    
    static let bundleUrl: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "com.mamiksik.Maturitka")!

    static func runAppleScript(withName: Scripts, parameters: String? = nil){
        let path = Bundle.main.url(forResource: withName.rawValue, withExtension: "scpt")!.path
        print(path)
        
        if parameters == Options.keep.description {
            return
        }
        
        if parameters != nil {
            let result = try! shellOut(to: "osascript \"\(path)\" \(parameters!)")
            print(result)
        } else {
            let result = try! shellOut(to: "osascript \"\(path)\"")
            print(result)
        }
        
        
    }
}
