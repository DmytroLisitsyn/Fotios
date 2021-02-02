//
//  Fotios
//
//  Copyright (C) 2019 Dmytro Lisitsyn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
