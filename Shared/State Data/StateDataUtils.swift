
//
//  SaveStateDataUtils.swift
//  DesktopProfiles
//
//  Created by Martin Miksik on 28/03/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Foundation

class StateDataUtils {
    static func copy(from: URL, to: URL) throws {
        let fm = FileManager.default
        if fm.isReadableFile(atPath: from.path) {
            try? fm.copyItem(at: from, to: to)
        }
    }
    
    static func clean(at: URL) throws {
        let fm = FileManager.default
        if fm.isDeletableFile(atPath: at.path){
            try fm.removeItem(atPath: at.path)
        }
    }
    
    static func createDirectory(at: URL) throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: at.path) {
            try fm.createDirectory(at: at, withIntermediateDirectories: true, attributes: [:])
        }
    }
    
    static func stateDataPath(library: URL, bundle: String) -> URL{
        return library.appendingPathComponent("\(bundle).savedState")
    }
}
