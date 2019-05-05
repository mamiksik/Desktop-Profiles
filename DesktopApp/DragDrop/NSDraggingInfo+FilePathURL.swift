//
//  NSDraggingInfo+FilePathURL.swift
//  ADragDropViewExample
//
//  Created by Soulchild on 24/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import Foundation
import AppKit

extension NSDraggingInfo {
    var filePathURLs: [URL] {
        var filenames : [String]?
        var urls: [URL] = []
        
        if #available(OSX 10.13, *) {
            filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        } else {
            // Fallback on earlier versions
            filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        }
        
        if let filenames = filenames {
            for filename in filenames {
                urls.append(URL(fileURLWithPath: filename))
            }
            return urls
        }
        
        return []
    }
}
