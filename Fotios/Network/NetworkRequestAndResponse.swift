//
//  NetworkRequestAndResponse.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
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
    
    associatedtype Response
    
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

extension NetworkResponse {

    init(_ networkBody: Data) throws {
        throw NetworkError.unexpectedResponse(context: .errorContext(entity: Self.self, file: #file, line: #line))
    }

}
