//
//  Copyright (C) 2022 Dmytro Lisitsyn
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

public struct JSON {

    public var raw: Any?
    
    public init(_ raw: Any? = nil) {
        self.raw = raw
    }

    public init(jsonData: Data?) {
        if let jsonData = jsonData, let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) {
            self.raw = jsonObject
        }
    }

    public init(jsonString: String?) {
        self.init(jsonData: jsonString?.data(using: .utf8))
    }

    public subscript(_ key: String) -> JSON {
        get {
            let json = JSON(dictionary?[key])
            return json
        }
        set {
            var modified = dictionaryValue
            modified[key] = newValue.raw
            raw = modified
        }
    }
    
}

extension JSON {
    
    public var number: NSNumber? {
        return raw as? NSNumber
    }
    
    public var bool: Bool? {
        return number?.boolValue
    }
    
    public var boolValue: Bool {
        return bool ?? false
    }
    
    public var int: Int? {
        return number?.intValue
    }
    
    public var intValue: Int {
        return int ?? 0
    }
    
    public var float: Float? {
        return number?.floatValue
    }
    
    public var floatValue: Float {
        return float ?? 0
    }
    
    public var double: Double? {
        return number?.doubleValue
    }
    
    public var doubleValue: Double {
        return double ?? 0
    }
    
    public var string: String? {
        return raw as? String
    }
    
    public var stringValue: String {
        return string ?? ""
    }
    
    public var url: URL? {
        return URL(string: stringValue)
    }
    
    public var dictionary: [String: Any]? {
        return raw as? [String: Any]
    }
    
    public var dictionaryValue: [String: Any] {
        return dictionary ?? [:]
    }
    
    public var array: [Any]? {
        return raw as? [Any]
    }
    
    public var arrayValue: [Any] {
        return array ?? []
    }
    
    public func map<T>(_ transform: (JSON) throws -> T) rethrows -> T? {
        if let raw = raw {
            return try transform(JSON(raw))
        } else {
            return nil
        }
    }
    
    public func map<T>(_ transform: (JSON) throws -> T) rethrows -> [T] {
        return try arrayValue.map({ try transform(JSON($0)) })
    }

    public var jsonData: Data? {
        if let raw = raw, JSONSerialization.isValidJSONObject(raw) {
            return try? JSONSerialization.data(withJSONObject: raw)
        } else {
            return nil
        }
    }

    public var jsonString: String? {
        if let data = jsonData, let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            return nil
        }
    }

}

extension JSON: CustomStringConvertible {
    
    public var description: String {
        let string: String
        
        if let jsonString = jsonString {
            string = jsonString
        } else if let raw = raw as? CustomStringConvertible {
            string = raw.description
        } else {
            string = raw.debugDescription
        }
        
        return string
    }
    
}
