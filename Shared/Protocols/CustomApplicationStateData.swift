//
//  MMStateData.swift
//  CabinetproX
//
//  Created by Martin Miksik on 21/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

import Foundation

protocol CustomApplicationStateData {    
    func copy() throws -> Void
    func restore() throws -> Void
    func clean() throws -> Void
}
