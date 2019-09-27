//
//  NetworkSession.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import UIKit

public typealias NetworkSessionResponse = (data: Data?, meta: URLResponse?, error: Error?)

public protocol NetworkSession {
    
    @discardableResult
    func send(_ request: URLRequest, completionHandler: @escaping (NetworkSessionResponse) -> Void) -> NetworkTask
    
}

extension URLSession: NetworkSession {
    
    @discardableResult
    public func send(_ request: URLRequest, completionHandler: @escaping (NetworkSessionResponse) -> Void) -> NetworkTask {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            completionHandler((data, response, error))
        }
        
        task.resume()
        
        return task
    }
    
}

public class MockNetworkSession {
    
    public var data: Data?
    public var statusCode: Int
    public var callbackError: Error?
    public var task = MockNetworkTask()
    
    public init(bundle: Bundle = .main, jsonResource: String? = nil, statusCode: Int = 200, callbackError: Error? = nil) {
        if let jsonResource = jsonResource {
            let url = bundle.url(forResource: jsonResource, withExtension: "json")!
            data = try! Data(contentsOf: url)
        }
        
        self.statusCode = statusCode
        self.callbackError = callbackError
    }
    
    public init(json: Any, statusCode: Int = 200, callbackError: Error? = nil) {
        data = try? JSONSerialization.data(withJSONObject: json)
        
        self.statusCode = statusCode
        self.callbackError = callbackError
    }
    
}

extension MockNetworkSession: NetworkSession {
    
    public func send(_ request: URLRequest, completionHandler: @escaping (NetworkSessionResponse) -> Void) -> NetworkTask {
        let url = request.url!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        DispatchQueue.global(qos: .userInitiated).async { [data, callbackError] in
            completionHandler((data, response, callbackError))
        }
        
        return task
    }
        
}
