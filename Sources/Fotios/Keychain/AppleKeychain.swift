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

public final class AppleKeychain: Keychain {
    
    public init() {
        
    }
    
    public func save(_ value: Data?, as item: KeychainItem, account: String?) throws {
        try delete(item, account: account)

        guard let value = value else { return }
        
        let tag = makeTag(from: item, account: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessible as String: item.accessModifier,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: value
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }
    
    public func fetch(_ item: KeychainItem, account: String?) throws -> Data {
        let tag = makeTag(from: item, account: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
            kSecAttrApplicationTag as String: tag
        ]
        
        var ref: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &ref)
        
        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
        
        return ref as! Data
    }
    
    public func delete(_ item: KeychainItem, account: String?) throws {
        let tag = makeTag(from: item, account: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
            break
        default:
            throw KeychainError(status: status)
        }
    }
    
}

extension AppleKeychain {
    
    private func makeTag(from item: KeychainItem, account: String?) -> Any {
        if let account = account {
            let tag = "\(account).\(item.tag)".data(using: .utf8) as Any
            return tag
        } else {
            let tag = "\(item.tag)".data(using: .utf8) as Any
            return tag
        }
    }
    
}
