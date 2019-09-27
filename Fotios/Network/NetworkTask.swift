//
//  NetworkTask.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public protocol NetworkTask: AnyObject {
    
    func cancel()
    
}

extension URLSessionDataTask: NetworkTask {
    
}

public class MockNetworkTask {
    
    public var cancelAction: Closure<Void>?
    
    public init(cancelAction: Closure<Void>? = nil) {
        self.cancelAction = cancelAction
    }
    
}

extension MockNetworkTask: NetworkTask {
    
    public func cancel() {
        cancelAction?(())
    }
    
}
