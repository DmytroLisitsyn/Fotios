//
//  NetworkEnvironment.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public protocol NetworkEnvironment {
    
    var apiURL: URL { get }
    
}

extension NetworkEnvironment {
    
    public func apiURL(path: String, query: [String: String?] = [:]) -> URL {
        var components = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)!
        components.path += path
        
        if !query.isEmpty {
            components.queryItems = []
            
            for (name, value) in query {
                let item = URLQueryItem(name: name, value: value)
                components.queryItems?.append(item)
            }
        }
        
        return components.url!
    }
    
}

public protocol NetworkEnvironmentObserver: AnyObject {
    func didUpdateEnvironment(_ networkEnvironmentFetcher: NetworkEnvironmentFetcher)
}

public final class NetworkEnvironmentFetcher: ObserverContainable {
    
    public var environment: NetworkEnvironment {
        didSet { didSetEnvironment(environment) }
    }
    
    public var observers = ObserverContainer<NetworkEnvironmentObserver>()
    
    public init(environment: NetworkEnvironment) {
        self.environment = environment
    }
    
    private func didSetEnvironment(_ environment: NetworkEnvironment) {
        observers.enumerateObservers { observer in
            observer.didUpdateEnvironment(self)
        }
    }
    
}
