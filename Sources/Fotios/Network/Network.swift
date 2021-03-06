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

public final class Network {

    public let contextFetcher: NetworkContextFetcher
    
    public var session: NetworkSession
    
    public var recoverer: NetworkRequestRecoverer?
    
    public init(contextFetcher: NetworkContextFetcher, session: NetworkSession) {
        self.contextFetcher = contextFetcher
        self.session = session
    }
    
    public convenience init(context: NetworkContextRepresentable, session: NetworkSession) {
        self.init(contextFetcher: .init(context: context), session: session)
    }
    
    @discardableResult
    public func send<T: NetworkRequest>(_ request: T, shouldTryToRecoverFromError: Bool = true, completionHandler: @escaping (TypedResult<T.NetworkSuccess>) -> Void) -> NetworkTask {
        let urlRequest = request.networkRequest(in: contextFetcher.context)
        
        return session.send(urlRequest) { response in
            do {
                if let error = response.error {
                    throw error
                }
                
                let data = response.data ?? Data()
                let meta = response.meta as? HTTPURLResponse
                
                guard let statusCode = meta?.statusCode, statusCode < 400 else {
                    let error = try T.NetworkFailure(networkBody: data, statusCode: meta?.statusCode ?? -1)
                    throw error
                }
                
                let networkResponse = try T.NetworkSuccess(networkBody: data)
                completionHandler(.success(networkResponse))
            } catch let error {
                guard let recoverer = self.recoverer else {
                    completionHandler(.failure(error))
                    return
                }
                
                recoverer.network(self, didAskForRecoveryAfter: request, from: error, shouldForceFailure: !shouldTryToRecoverFromError, successHandler: {
                    self.send(request, shouldTryToRecoverFromError: false, completionHandler: completionHandler)
                }, failureHandler: {
                    completionHandler(.failure(error))
                })
            }
        }
    }

}
