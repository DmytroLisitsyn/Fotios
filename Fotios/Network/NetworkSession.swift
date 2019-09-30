//
//  Fotios
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

import UIKit

public typealias NetworkSessionResponse = (data: Data?, meta: URLResponse?, error: Error?)

// MARK: NetworkSession

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

// MARK: MockNetworkSession

public class MockNetworkSession: NetworkSession {
    
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
    
    public func send(_ request: URLRequest, completionHandler: @escaping (NetworkSessionResponse) -> Void) -> NetworkTask {
        let url = request.url!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        DispatchQueue.global(qos: .userInitiated).async { [data, callbackError] in
            completionHandler((data, response, callbackError))
        }
        
        return task
    }
        
}
