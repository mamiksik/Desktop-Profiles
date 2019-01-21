//
//  MacOSDefaultSaveStateData.swift
//  CabinetproX
//
//  Created by Martin Miksik on 21/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Foundation
final class MacOSDefaultSaveStateData: CustomApplicationStateData {
    let profile: Profile
    let app: App
    
    private let fm = FileManager.default
    private let sourceData: String
    private let bundleData: String
//    private let fileQueue = DispatchQueue(label: CustomQueue.files.rawValue)
    
    init(_ app: App) {
        self.app = app.detached()
        self.profile = app.profile.detached()
        
        let libraryFolder = self.fm.homeDirectoryForCurrentUser
        self.sourceData = libraryFolder.appendingPathComponent("Library/Saved Application State").path
        self.bundleData = Utils.bundleUrl.appendingPathComponent("Saved Application State/").path
    }
    
    
    func copy() throws {
        try? app.close()
        
        let source = pathToSource(forAppBundle: app.bundleIdentifier)
        let copy = pathToCopy(forAppBundle: app.bundleIdentifier, forProfile: profile.name)
        
        let dirUrl = URL(fileURLWithPath: bundleData + "/\(profile.name)/")
        if !fm.fileExists(atPath: dirUrl.path) {
            try? fm.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: [:])
        }
        
        //TODO - Rises erroe
        if self.fm.isDeletableFile(atPath: copy){
            try? self.fm.removeItem(atPath: copy)
        }
        
        if self.fm.isDeletableFile(atPath: source){
            try? self.fm.copyItem(atPath: source, toPath: copy)
        }
        
    
        try? app.open()
    }
    
    func restore() throws {
        try? app.close()
        
        let source = pathToSource(forAppBundle: app.bundleIdentifier)
        let copy = pathToCopy(forAppBundle: app.bundleIdentifier, forProfile: profile.name)
        
        //TODO - Rises erroe
        if self.fm.isDeletableFile(atPath: source){
            try? self.fm.removeItem(atPath: source)
        }
        
        if self.fm.isReadableFile(atPath: copy) {
            try? self.fm.copyItem(atPath: copy, toPath: source)
        }
        
        try? app.open()
    }
    
    func clean() throws {
        let copy = pathToCopy(forAppBundle: app.bundleIdentifier, forProfile: profile.name)
        if fm.isDeletableFile(atPath: copy){
            try? fm.removeItem(atPath: copy)
        }
    }
    
    private func pathToSource(forAppBundle: String) -> String {
        return "\(sourceData)/\(forAppBundle).savedState"
    }
    
    private func pathToCopy(forAppBundle: String, forProfile: String) -> String {
        return "\(bundleData)/\(forProfile)/" + forAppBundle + ".savedState"
    }
}
