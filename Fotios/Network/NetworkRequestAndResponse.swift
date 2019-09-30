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


import Foundation

// MARK: NetworkRequest

public protocol AnyNetworkRequest {
    
    func networkRequest(in environment: NetworkEnvironment) throws -> URLRequest
    
    func networkURL(in environment: NetworkEnvironment) throws -> URL
    func networkURLPath(in environment: NetworkEnvironment) throws -> String
    func networkURLQuery(in environment: NetworkEnvironment) throws -> [String: String?]
    
    func networkMethod(in environment: NetworkEnvironment) -> String
    func networkHeaderFields(in environment: NetworkEnvironment) throws -> [String: String]
    func networkBody(in environment: NetworkEnvironment) throws -> Data?

}

public protocol NetworkRequest: AnyNetworkRequest {
    
    associatedtype NetworkResponse: Fotios.NetworkResponse
    associatedtype NetworkError: Fotios.NetworkError
    
}

extension NetworkRequest {
    
    public func networkRequest(in environment: NetworkEnvironment) throws -> URLRequest {
        let url = try networkURL(in: environment)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkMethod(in: environment)
        urlRequest.allHTTPHeaderFields = try networkHeaderFields(in: environment)
        urlRequest.httpBody = try networkBody()
        
        return urlRequest
    }
    
    public func networkURL(in environment: NetworkEnvironment) throws -> URL {
        let path = try networkURLPath(in: environment)
        let query = try networkURLQuery(in: environment)
        return environment.apiURL(path: path, query: query)
    }

    public func networkURLPath(in environment: NetworkEnvironment) throws -> String {
        return ""
    }
    
    public func networkURLQuery(in environment: NetworkEnvironment) throws -> [String: String?] {
        return [:]
    }
    
    public func networkMethod(in environment: NetworkEnvironment) -> String {
        return "GET"
    }
    
    public func networkHeaderFields(in environment: NetworkEnvironment) throws -> [String: String] {
        return [:]
    }
    
    public func networkBody() throws -> Data? {
        return nil
    }

}

// MARK: NetworkResponse

public protocol NetworkResponse {

    init(_ networkBody: Data) throws

}
