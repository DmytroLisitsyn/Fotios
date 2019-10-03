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

// MARK: Keychain

public protocol Keychain {
    
    init(account: String)
    
    func save(_ value: Data, as item: KeychainItem) throws
    func fetch(_ item: KeychainItem) throws -> Data?
    func delete(_ item: KeychainItem) throws
    
}

// MARK: KeychainItem

public struct KeychainItem: Hashable {
    
    public var tag: String
    
    public var accessModifier = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    
    public init(tag: String) {
        self.tag = tag
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }

}

// MARK: KeychainError

public struct KeychainError: Error {
    
    public var status: OSStatus
    
    public init(status: OSStatus) {
        self.status = status
    }
    
}
