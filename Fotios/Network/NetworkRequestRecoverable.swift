//
//  NetworkRequestRecoverable.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public protocol NetworkRequestRecoverable {
    
    func tryToRecover(from error: Error, shouldForceFailure: Bool, successHandler: @escaping Closure<Void>, failureHandler: @escaping Closure<Void>)
    
}

public protocol NetworkTokenRenewer {
    
    func networkRequestRecoverer(_ recoverer: NetworkRequestRecoverer, didRequestAccessTokenRenewal completionHandler: @escaping Closure<PlainResult>)
    
}

public protocol NetworkTokenDropper {
    
    func didRequestAccessTokenDrop(_ recoverer: NetworkRequestRecoverer)
    
}

public final class NetworkRequestRecoverer: NetworkRequestRecoverable {
    
    public var networkTokenRenewer: NetworkTokenRenewer?
    public var networkTokenDropper: NetworkTokenDropper?
    
    public func tryToRecover(from error: Error, shouldForceFailure: Bool, successHandler: @escaping Closure<Void>, failureHandler: @escaping Closure<Void>) {
        if shouldForceFailure {
            failureHandler(())
            return
        }
        
        switch error {
        case NetworkError.unauthorized where networkTokenRenewer != nil:
            networkTokenRenewer?.networkRequestRecoverer(self, didRequestAccessTokenRenewal: { result in
                do {
                    try result.get()
                    
                    successHandler(())
                } catch {
                    if let networkTokenDropper = self.networkTokenDropper {
                        networkTokenDropper.didRequestAccessTokenDrop(self)
                    } else {
                        failureHandler(())
                    }
                }
            })
        default:
            failureHandler(())
        }
    }

}
