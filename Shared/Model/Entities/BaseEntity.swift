//
//  BaseEntity.swift
//  CabinetproX
//
//  Created by Martin Miksik on 21/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Foundation
import RealmSwift

class BaseEntity: Object {
    @objc var id = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
