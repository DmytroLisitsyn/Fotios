//
//  Network.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public final class Network {

    public let environmentFetcher: NetworkEnvironmentFetcher
    
    public var session: NetworkSession
    
    public var recoverer: NetworkRequestRecoverable = NetworkRequestRecoverer()
    
    public init(environmentFetcher: NetworkEnvironmentFetcher, session: NetworkSession) {
        self.environmentFetcher = environmentFetcher
        self.session = session
    }
    
    public convenience init(environment: NetworkEnvironment, session: NetworkSession) {
        self.init(environmentFetcher: .init(environment: environment), session: session)
    }
    
    public func send<T: NetworkRequest>(_ request: T, shouldTryToRecoverFromError: Bool = true, completionHandler: @escaping (TypedResult<T.Response>) -> Void) {
        let handleError: (Error) -> Void = { error in
            self.recoverer.tryToRecover(from: error, shouldForceFailure: !shouldTryToRecoverFromError, successHandler: {
                self.send(request, shouldTryToRecoverFromError: false, completionHandler: completionHandler)
            }, failureHandler: {
                completionHandler(.failure(error))
            })
        }
        
        do {
            let urlRequest = try request.networkRequest(in: environmentFetcher.environment)
            session.send(urlRequest) { response in
                do {
                    let result: T.Response = try self.entity(from: response)
                    completionHandler(.success(result))
                } catch let error {
                    handleError(error)
                }
            }
        } catch let error {
            handleError(error)
        }
    }

}

extension Network {
    
    private func entity<T>(from data: Data) throws -> T {
        switch T.self {
        case is Void.Type:
            return () as! T
        case (let type as NetworkResponse.Type):
            let entity = try type.init(data) as! T
            return entity
        default:
            throw NetworkError.undefinedMapper(context: .errorContext(entity: T.self, file: #file, line: #line))
        }
    }
    
    private func entity<T>(from response: NetworkSessionResponse) throws -> T {
        let data = try self.data(from: response)
        let entity: T = try self.entity(from: data)
        return entity
    }
    
    private func data(from response: NetworkSessionResponse) throws -> Data {
        if let error = response.error {
            if (error as NSError).code == NSURLErrorCancelled {
                throw NetworkError.cancelled
            } else {
                throw error
            }
        }
        
        guard let data = response.data, let meta = response.meta as? HTTPURLResponse else {
            throw NetworkError.unexpectedResponse(context: .errorContext(entity: NetworkSessionResponse.self, file: #file, line: #line))
        }
        
        if meta.statusCode < 400 {
            return data
        }
        
        if let error = try? entity(from: data) as NetworkError {
            throw error
        } else if let error = NetworkError(errorCode: meta.statusCode) {
            throw error
        } else if let message = String(data: data, encoding: .utf8) {
            throw NetworkError.unknown(message: message)
        } else {
            throw NetworkError.unexpectedResponse(context: .errorContext(entity: NetworkSessionResponse.self, file: #file, line: #line))
        }
    }

}
