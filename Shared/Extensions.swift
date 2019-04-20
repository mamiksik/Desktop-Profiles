/* Copyright (C) Martin Miksik 2019

   This file is part of Desktop Profile

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/


import Foundation
import Cocoa
import Magnet
import RealmSwift

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
                if let detached = detachable.detached() as? Element {
                    result.append(detached)
                }
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
