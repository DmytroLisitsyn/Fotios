//
//  HashableExtension.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public func ==<T: Hashable>(lhs: T, rhs: T) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
