//
//  JSONExtension.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

extension Data {
    
    init(entityJSON: [String: Any]) throws {
        self = try JSONSerialization.data(withJSONObject: entityJSON, options: .sortedKeys)
    }
    
    func entityJSON() throws -> [String: Any] {
        let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        
        if let json = json as? [String: Any] {
            return json
        } else {
            throw NetworkError.unexpectedResponse(context: .errorContext(entity: [String: Any].self, file: #file, line: #line))
        }
    }
    
    func listJSON() throws -> [[String: Any]] {
        let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        
        if let json = json as? [[String: Any]] {
            return json
        } else {
            throw NetworkError.unexpectedResponse(context: .errorContext(entity: [String: Any].self, file: #file, line: #line))
        }
    }
    
    func listJSONData() throws -> [Data] {
        return try listJSON().map(Data.init)
    }
    
}
