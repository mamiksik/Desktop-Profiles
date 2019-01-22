//
//  ChromeStateData.swift
//  CabinetproX
//
//  Created by Martin Miksik on 21/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Foundation

final class ChromeStateData : CustomApplicationStateData {
    let profile: Profile
    let app: App
    
    private let fm = FileManager.default
    private let sourceFolder: URL
    private let bundleData: URL
    
    private let chromeProfiles = ["Default", "Profile 1", "Profile 2", "Profile 3", "Profile 4", "Profile 5"]
    private let toCopy = ["Current Session", "Current Tabs"]
    
    init(_ app: App) {
        self.app = app.detached()
        self.profile = app.profile.detached()
        
        let homeFolder = self.fm.homeDirectoryForCurrentUser
        self.sourceFolder = homeFolder.appendingPathComponent("Library/Application Support/Google/Chrome")
        self.bundleData = Utils.bundleUrl.appendingPathComponent("\(profile.name)/Chrome")
    }
    
    
    func copy() throws {
        try? app.close()

        for chromeProfile in chromeProfiles {
            let dirUrl = URL(fileURLWithPath: bundleData.path + "/\(chromeProfile)/")
            if !fm.fileExists(atPath: dirUrl.path) {
                try fm.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: [:])
            }
            
            let currentSessionSource = currentSessionURL(sourceFolder, forProfile: chromeProfile)
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentSessionSource) {
                try? self.fm.copyItem(atPath: currentSessionSource, toPath: currentSessionCopy)
            }
            
            let currentTabsSource = currentTabsURL(sourceFolder, forProfile: chromeProfile)
            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentTabsSource) {
                try? self.fm.copyItem(atPath: currentTabsSource, toPath: currentTabsCopy)
            }
        }
        
        try? app.open()
    }
    
    func restore() throws {
        try? app.close()
        
        for chromeProfile in chromeProfiles {
            let currentSessionSource = currentSessionURL(sourceFolder, forProfile: chromeProfile)
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentSessionCopy) {
                try? self.fm.removeItem(atPath: currentSessionSource)
                try? self.fm.copyItem(atPath: currentSessionCopy, toPath: currentSessionSource)
            }
            
            let currentTabsSource = currentTabsURL(sourceFolder, forProfile: chromeProfile)
            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isReadableFile(atPath: currentTabsCopy) {
                try? self.fm.removeItem(atPath: currentTabsSource)
                try? self.fm.copyItem(atPath: currentTabsCopy, toPath: currentTabsSource)
            }
        }
        
        try? app.open()
    }
    
    func clean() throws {
        for chromeProfile in chromeProfiles {
            let currentSessionCopy = currentSessionURL(bundleData, forProfile: chromeProfile)
            if self.fm.isDeletableFile(atPath: currentSessionCopy) {
                try self.fm.removeItem(atPath: currentSessionCopy)
            }
    
            let currentTabsCopy = currentTabsURL(bundleData, forProfile: chromeProfile)
            if self.fm.isDeletableFile(atPath: currentTabsCopy) {
                try self.fm.removeItem(atPath: currentTabsCopy)
            }
        }
    }
    
    private func currentSessionURL(_ path: URL, forProfile: String) -> String {
        return path.appendingPathComponent("\(forProfile)/Current Session").path
    }
    
    private func currentTabsURL(_ path: URL, forProfile: String) -> String {
        return path.appendingPathComponent("\(forProfile)/Current Tabs").path
    }
}
