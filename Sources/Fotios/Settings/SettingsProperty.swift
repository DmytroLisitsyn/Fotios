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
import Combine

public protocol AnySettingsProperty: AnyObject {
    func setUserDefaults(_ userDefaults: UserDefaults?)
}

@propertyWrapper
public final class SettingsProperty<T: SettingsValue>: AnySettingsProperty {

    public var projectedValue: AnyPublisher<T, Never> {
        return settingsValueSubject.eraseToAnyPublisher()
    }

    public var wrappedValue: T {
        get {
            return settingsValueSubject.value
        }
        set {
            newValue.storeSettingsValue(for: key, in: userDefaults)
            settingsValueSubject.value = newValue
        }
    }

    public let key: String

    private var settingsValueSubject: CurrentValueSubject<T, Never>
    private var userDefaults: UserDefaults?

    public init(wrappedValue: T, key: String) {
        self.settingsValueSubject = .init(wrappedValue)
        self.key = key
    }

    public func setUserDefaults(_ userDefaults: UserDefaults?) {
        self.userDefaults = userDefaults

        if let value = T.fetchSettingsValue(for: key, from: userDefaults), !value.isSettingsValueNil {
            settingsValueSubject.value = value
        }
    }

}
