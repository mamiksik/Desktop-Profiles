//
//  Extensions.swift
//  Maturitka
//
//  Created by Martin Miksik on 30/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift
import Magnet

// MARK - Nested types

extension NSUserInterfaceItemIdentifier {
    static let check = NSUserInterfaceItemIdentifier(rawValue: "check")
    static let name = NSUserInterfaceItemIdentifier(rawValue: "name")
    static let icon = NSUserInterfaceItemIdentifier(rawValue: "icon")
}

// MARK - Localization

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

// MARK - Realm

extension Object: DetachableObject {
    
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            
            if property.isArray == true {
                //Realm List property support
                let detachable = value as? DetachableObject
                detached.setValue(detachable?.detached(), forKey: property.name)
            } else if property.type == .object {
                //Realm Object property support
                let detachable = value as? DetachableObject
                detached.setValue(detachable?.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

extension List: DetachableObject {
    func detached() -> List<Element> {
        let result = List<Element>()
        
        forEach {
            if let detachable = $0 as? DetachableObject {
                let detached = detachable.detached() as! Element
                result.append(detached)
            } else {
                result.append($0) //Primtives are pass by value; don't need to recreate
            }
        }
        
        return result
    }
    
    func toArray() -> [Element] {
        return Array(self.detached())
    }
}

extension Results {
    func toArray() -> [Element] {
        let result = List<Element>()
        
        forEach {
            result.append($0)
        }
        
        return Array(result.detached())
    }
}

extension KeyCombo {
    var cocoaFlags: NSEvent.ModifierFlags  {
        return KeyTransformer.cocoaFlags(from: self.modifiers)
    }
}
