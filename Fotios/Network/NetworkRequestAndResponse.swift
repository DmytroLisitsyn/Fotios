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
    
    func networkRequest(in context: NetworkContextRepresentable) -> URLRequest
    
    func networkURL(in context: NetworkContextRepresentable) -> URL
    func networkURLPath(in context: NetworkContextRepresentable) -> String
    func networkURLQuery(in context: NetworkContextRepresentable) -> [String: String?]
    
    func networkMethod(in context: NetworkContextRepresentable) -> String
    func networkHeaderFields(in context: NetworkContextRepresentable) -> [String: String]
    func networkBody(in context: NetworkContextRepresentable) -> Data?

}

public protocol NetworkRequest: AnyNetworkRequest {
    
    associatedtype NetworkResponse: Fotios.NetworkResponse
    associatedtype NetworkFailable: Fotios.NetworkFailable
    
}

extension NetworkRequest {
    
    public func networkRequest(in context: NetworkContextRepresentable) -> URLRequest {
        let url = networkURL(in: context)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = networkMethod(in: context)
        urlRequest.allHTTPHeaderFields = networkHeaderFields(in: context)
        urlRequest.httpBody = networkBody(in: context)
        
        return urlRequest
    }
    
    public func networkURL(in context: NetworkContextRepresentable) -> URL {
        let path = networkURLPath(in: context)
        let query = networkURLQuery(in: context)
        return context.apiURL(path: path, query: query)
    }

    public func networkURLPath(in context: NetworkContextRepresentable) -> String {
        return ""
    }
    
    public func networkURLQuery(in context: NetworkContextRepresentable) -> [String: String?] {
        return [:]
    }
    
    public func networkMethod(in context: NetworkContextRepresentable) -> String {
        return "GET"
    }
    
    public func networkHeaderFields(in context: NetworkContextRepresentable) -> [String: String] {
        return context.headerFields()
    }
    
    public func networkBody(in context: NetworkContextRepresentable) -> Data? {
        return nil
    }

}

// MARK: NetworkResponse

public protocol NetworkResponse {

    init(_ networkBody: Data) throws

}
