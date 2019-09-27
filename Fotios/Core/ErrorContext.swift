//
//  ErrorContext.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

extension String {
    
    public static func errorContext(entity: Any.Type, file: String, line: Int) -> String {
        let file = (file as NSString).lastPathComponent
        return "\(entity) (\(file), line: \(line))"
    }
    
}
