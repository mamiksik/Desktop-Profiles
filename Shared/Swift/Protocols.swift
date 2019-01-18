//
//  Protocols.swift
//  Maturitka
//
//  Created by Martin Miksik on 30/12/2018.
//  Copyright © 2018 Martin Miksik. All rights reserved.
//

import Foundation

protocol NameProtocol {
    var name: String { get set }
}

protocol DetachableObject: AnyObject {
    func detached() -> Self
}
