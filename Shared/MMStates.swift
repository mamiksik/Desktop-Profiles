////
////  ProfileManager.swift
////  Maturitka
////
////  Created by Martin Miksik on 19/12/2018.
////  Copyright © 2018 Martin Miksik. All rights reserved.
////
//
////import 
//import Foundation
//import ShellOut
//import ScriptingBridge
//
//class MMStates {
//    
//    private let queueFiles = DispatchQueue(label: "mamiksik.states")
//    private let queueScripts = DispatchQueue(label: "mamiksik.appleScript")
//    private let apps = MMApplications()
//    
//    private let fm = FileManager.default
//    private let sourceData: String
//    private let bundleData: String
//    
//    init() {
//        let libraryFolder = self.fm.homeDirectoryForCurrentUser
//        self.sourceData = libraryFolder.appendingPathComponent("Library/Saved Application State").path
//        self.bundleData = Utils.bundleUrl.appendingPathComponent("Saved Application State/").path
//    }
//    
//    func restore(fromProfile: Profile) {
//        let detachedProfile = fromProfile.detached()
//        
//        if ( detachedProfile.nightShift     != .keep ||
//             detachedProfile.darkMode       != .keep ||
//             detachedProfile.accentColour   != .keep ) {
//            queueScripts.async {
//                Utils.runAppleScript(withName: .OpenPreferences)
//                Utils.runAppleScript(withName: .NightShift, parameters: detachedProfile.nightShift.description)
//                Utils.runAppleScript(withName: .DarkMode, parameters: detachedProfile.darkMode.description)
//                Utils.runAppleScript(withName: .AccentColour, parameters: detachedProfile.accentColour.description)
//                Utils.runAppleScript(withName: .QuitPreferences)
//            }
//        }
//        
//        for workflow in detachedProfile.workflows {
//            let path = workflow.path.replacingOccurrences(of: " ", with: "\\ ")
//            queueScripts.async {
//                try! shellOut(to: "/usr/bin/automator", arguments: [path])
//            }
//        }
//        
//        if detachedProfile.closeOtherApps {
//            Utils.runAppleScript(withName: .KillRunningApplications)
//        }
//        
//        for app in detachedProfile.apps {
//            restore(fromProfile: detachedProfile, app: app)
//        }
//    }
//    
//    func restore(fromProfile: Profile, app: App) {
//        queueFiles.async {
//            self.apps.close(app: app)
//            self.restore(forAppBundle: app.bundleIdentifier, forProfile: fromProfile.name)
//            self.apps.open(app: app)
//        }
//    }
//    
//    func save(toProfile: Profile) {
//        let profile = toProfile.detached()
//        
//        for app in profile.apps {
//            queueFiles.async {
//                self.apps.close(app: app)
//                self.copy(forAppBundle: app.bundleIdentifier, forProfile: profile.name)
//                self.apps.open(app: app)
//            }
//        }
//    }
//    
//    func save(toProfile: Profile, app: App) {
//        self.apps.close(app: app)
//        self.copy(forAppBundle: app.bundleIdentifier, forProfile: toProfile.name)
//        self.apps.open(app: app)
//    }
//    
//    func clean(app: App, fromProfile: Profile){
//        clean(forAppBundle: app.bundleIdentifier, forProfile: fromProfile.name)
//    }
//
//    // MARK - SaveData managment
//    
//    private func copy(forAppBundle: String, forProfile: String) {
//
//        let source = pathToSource(forAppBundle: forAppBundle)
//        let copy = pathToCopy(forAppBundle: forAppBundle, forProfile: forProfile)
//        
//        let dirUrl = URL(fileURLWithPath: bundleData + "/\(forProfile)/")
//        NSLog(dirUrl.absoluteString)
//        if !fm.fileExists(atPath: dirUrl.path) {
//            try! fm.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: [:])
//        }
//        
//        if self.fm.isDeletableFile(atPath: copy){
//            try? self.fm.removeItem(atPath: copy)
//        }
//        try? self.fm.copyItem(atPath: source, toPath: copy)
//    }
//    
//    private func restore(forAppBundle: String, forProfile: String) {
//        let source = pathToSource(forAppBundle: forAppBundle)
//        let copy = pathToCopy(forAppBundle: forAppBundle, forProfile: forProfile)
//        
//        if self.fm.isDeletableFile(atPath: source){
//            try? self.fm.removeItem(atPath: source)
//        }
//            
//        try? self.fm.copyItem(atPath: copy, toPath: source)
//    }
//    
//    private func clean(forAppBundle: String, forProfile: String) {
//        let copy = pathToCopy(forAppBundle: forAppBundle, forProfile: forProfile)
//        if fm.isDeletableFile(atPath: copy){
//            try? fm.removeItem(atPath: copy)
//        }
//    }
//    
//    private func pathToSource(forAppBundle: String) -> String {
//        return "\(sourceData)/\(forAppBundle).savedState"
//    }
//    
//    private func pathToCopy(forAppBundle: String, forProfile: String) -> String {
//        return "\(bundleData)/\(forProfile)/" + forAppBundle + ".savedState"
//    }
//}
