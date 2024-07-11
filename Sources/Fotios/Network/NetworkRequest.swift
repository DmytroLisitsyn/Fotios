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

public protocol NetworkRequest {
    
    associatedtype NetworkSuccess: Fotios.NetworkSuccess
    associatedtype NetworkFailure: Fotios.NetworkFailure
    
    func makeURLRequest(in context: NetworkContext) -> URLRequest
    func prepareRequest(_ request: inout AnyNetworkRequest)

}

extension NetworkRequest {
    
    public func makeURLRequest(in context: NetworkContext) -> URLRequest {
        var request = AnyNetworkRequest(context: context)
        prepareRequest(&request)
        return request.makeURLRequest()
    }

}

// MARK: - AnyNetworkRequest

public struct AnyNetworkRequest {
    
    public enum Method: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    public let context: NetworkContext

    public var method: Method = .get
    public var overrideURL: URL?
    public var urlPath = ""
    public var urlQuery: [(name: String, value: String?)] = []
    public var overrideHeaderFields: [String: String]?
    public var headerFields: [String: String] = [:]
    public var body: Data?
    
    public init(context: NetworkContext) {
        self.context = context
    }
    
    public func makeURLRequest() -> URLRequest {
        let url = overrideURL ?? context.url(path: urlPath, query: urlQuery)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        
        if let overrideHeaderFields = overrideHeaderFields {
            urlRequest.allHTTPHeaderFields = overrideHeaderFields
        } else {
            var headerFields = context.headerFields(networkBody: body)
            headerFields.merge(self.headerFields, uniquingKeysWith: { $1 })
            urlRequest.allHTTPHeaderFields = headerFields
        }
        
        return urlRequest
    }
    
}
