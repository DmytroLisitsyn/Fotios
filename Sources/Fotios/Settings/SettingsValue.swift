//
//  Copyright (C) 2024 Dmytro Lisitsyn
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

public protocol SettingsValue {
    var isSettingsValueNil: Bool { get }
    func storeSettingsValue(for key: String, in userDefaults: UserDefaults?)
    static func fetchSettingsValue(for key: String, from userDefaults: UserDefaults?) -> Self?
}

extension SettingsValue {

    public var isSettingsValueNil: Bool {
        return false
    }

    public func storeSettingsValue(for key: String, in userDefaults: UserDefaults?) {
        userDefaults?.setValue(self, forKey: key)
    }

    public static func fetchSettingsValue(for key: String, from userDefaults: UserDefaults?) -> Self? {
        let value = userDefaults?.value(forKey: key) as? Self
        return value
    }

}

extension Optional: SettingsValue where Wrapped: SettingsValue {

    public var isSettingsValueNil: Bool {
        return self == nil
    }

    public func storeSettingsValue(for key: String, in userDefaults: UserDefaults?) {
        if let value = self {
            value.storeSettingsValue(for: key, in: userDefaults)
        } else {
            userDefaults?.removeObject(forKey: key)
        }
    }

    public static func fetchSettingsValue(for key: String, from userDefaults: UserDefaults?) -> Self? {
        let value = Wrapped.fetchSettingsValue(for: key, from: userDefaults)
        return value
    }

}

// MARK: - Conformance

extension Int: SettingsValue {

}

extension Bool: SettingsValue {

}

extension Double: SettingsValue {

}

extension String: SettingsValue {

}

extension URL: SettingsValue {

}

extension Date: SettingsValue {

}

extension Data: SettingsValue {

}

// MARK: Codable

public protocol SettingsValueAsCodable: SettingsValue, Codable {

}

extension SettingsValueAsCodable {

    public func storeSettingsValue(for key: String, in userDefaults: UserDefaults?) {
        guard let data = try? JSONEncoder().encode(self) else { return }

        data.storeSettingsValue(for: key, in: userDefaults)
    }

    public static func fetchSettingsValue(for key: String, from userDefaults: UserDefaults?) -> Self? {
        guard let data = Data.fetchSettingsValue(for: key, from: userDefaults) else {
            return nil
        }

        let value = try? JSONDecoder().decode(Self.self, from: data)
        return value
    }

}
