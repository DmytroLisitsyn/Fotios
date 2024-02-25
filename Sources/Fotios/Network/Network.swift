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
    
    @Published public var session: NetworkSession
    @Published public var context: NetworkContext

    public var recoverer: NetworkRecovery?

    public init(session: NetworkSession, context: NetworkContext) {
        self.session = session
        self.context = context
    }
    
    @discardableResult
    public func send<T: NetworkRequest>(_ request: T, shouldTryToRecover: Bool = true) async throws -> T.NetworkSuccess {
        do {
            let urlRequest = request.makeURLRequest(in: context)
            let (data, response) = try await session.send(urlRequest)
            
            guard response.statusCode < 400 else {
                let error = try T.NetworkFailure(networkBody: data, statusCode: response.statusCode)
                throw error as Error
            }
            
            let success = try T.NetworkSuccess(networkBody: data)
            return success
        } catch {
            guard let recoverer = self.recoverer else {
                throw error
            }
            
            do {
                var recoveryRequest = NetworkRecoveryRequest(failedRequest: request, error: error)
                recoveryRequest.allowsRecurringRecovery = shouldTryToRecover
                try await recoverer.recover(with: recoveryRequest, network: self)
                
                let success = try await send(request, shouldTryToRecover: false)
                return success
            } catch {
                throw error
            }
        }
    }
    
}
