//
//  DispatchQueueExtension.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    public func wrap<Input>(_ block: @escaping (Input) -> Void) -> (Input) -> Void {
        return { input in
            self.async {
                block(input)
            }
        }
    }
    
}
