//
//  ADragDropView.swift
//  ADragDropViewExample
//
//  Created by Soulchild on 24/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import Cocoa

public final class ADragDropView: NSView {
    
    // highlight the drop zone when mouse drag enters the drop view
    fileprivate var highlight : Bool = false
    
    // check if the dropped file type is accepted
    fileprivate var fileTypeIsOk = false
    
    
    /// Allowed file type extensions to drop, eg: ["png", "jpg", "jpeg"]
    public var acceptedFileExtensions : [String] = []
    
    public weak var delegate: ADragDropViewDelegate?
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        } else {
            // Fallback on earlier versions
            registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    // MARK: - NSDraggingDestination
    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        highlight = true
        fileTypeIsOk = isExtensionAcceptable(draggingInfo: sender)
        
        self.setNeedsDisplay(self.bounds)
        return []
    }
    
    public override func draggingExited(_ sender: NSDraggingInfo?) {
        highlight = false
        self.setNeedsDisplay(self.bounds)
    }
    
    public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    public override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // finished with dragging so remove any highlighting
        highlight = false
        self.setNeedsDisplay(self.bounds)
        
        return true
    }
    
    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.filePathURLs.count == 0 {
            return false
        }
        
        if(fileTypeIsOk) {
            if sender.filePathURLs.count == 1 {
                delegate?.dragDropView(self, droppedFileWithURL: sender.filePathURLs.first!)
            } else {
                delegate?.dragDropView(self, droppedFilesWithURLs: sender.filePathURLs)
            }
        } else {
            
        }
        
        return true
    }
    
    fileprivate func isExtensionAcceptable(draggingInfo: NSDraggingInfo) -> Bool {
        if draggingInfo.filePathURLs.count == 0 {
            return false
        }
        
        for filePathURL in draggingInfo.filePathURLs {
            let fileExtension = filePathURL.pathExtension.lowercased()
            
            if !acceptedFileExtensions.contains(fileExtension){
                return false
            }
        }
        
        return true
    }
    
    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
}

public protocol ADragDropViewDelegate: class {
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL  URL: URL)
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL])
}

extension ADragDropViewDelegate {
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL  URL: URL) {
    }
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
    }
}
