//
//  NetworkError.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    
    case unauthorized
    case badGateway
    case notFound
    case timeout
    case cancelled
    
    case unknown(message: String)
    
    case unexpectedResponse(context: String)
    case undefinedMapper(context: String)
    case undefinedRequestFactory(context: String)
    
    init?(errorCode: Int) {
        switch errorCode {
        case 401:
            self = .unauthorized
        case 404:
            self = .notFound
        case 408:
            self = .timeout
        case 502:
            self = .badGateway
        default:
            return nil
        }
    }
        
}
