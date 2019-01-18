//
//  AppDelegate.swift
//  Maturitka
//
//  Created by Martin Miksik on 12/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Cocoa
import RealmSwift
import ShellOut
import Magnet
import SwiftSocket


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let spaces = MMSpaces.Shared.spaces;
        NSLog(spaces.description)
//
//        let string: Unmanaged<CFString> = AXLibGetDisplayIdentifierForMainDisplay()
//        print(string.takeUnretainedValue())
//        let spaces = AXLibSpacesForMainDisplay()
//        print(spaces) 
////        let CGSpaceId = AXLibActiveSpaceIdentifier(string.takeUnretainedValue(), )
//        
//        let client = TCPClient(address: "localhost", port: 5050)
//        
//        switch client.connect(timeout: 10) {
//        case .success:
////            cl    ient.send(string: "space 6")
//            client.send(string: "space_create 5")
////            client.send(string: "space_create 6")
//            print("sending")
//        case .failure(let error):
//            print("💩")
//        }
//        return
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

