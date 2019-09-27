//
//  OptionalExtension.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

extension Optional {
    
    public func unwrapped<Type>(or entity: Type) -> Type {
        return (self as? Type) ?? entity
    }
    
    public func unwrapped<Type>(orMake makingBlock: () -> Type) -> Type {
        return (self as? Type) ?? makingBlock()
    }
    
    @discardableResult
    public mutating func unwrap<Type>(or entity: Type) -> Type {
        let instance = unwrapped(or: entity)
        self = instance as? Wrapped
        return instance
    }

    @discardableResult
    public mutating func unwrap<Type>(orMake makingBlock: () -> Type) -> Type {
        let instance = unwrapped(orMake: makingBlock)
        self = instance as? Wrapped
        return instance
    }
    
}
