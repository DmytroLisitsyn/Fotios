//
//  ListAndResults.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public typealias Closure<T> = (T) -> Void

public typealias PlainResult = TypedResult<Void>
public typealias TypedResult<T> = Result<T, Error>

public protocol AnyList {
    
    static var entityType: Any.Type { get }
    
    var count: Int { get }

    var metadata: ListMetadata { get set }

}

public struct List<T>: AnyList {

    public static var entityType: Any.Type {
        return T.self
    }

    public var entities: [T] = []
    
    public var count: Int {
        return entities.count
    }

    public var metadata: ListMetadata = .init()

    public init() {
        
    }
    
}

public struct ListMetadata {
     
     public var page = 0
     public var countPerPage = 0
     public var count = 0
     
     public var hasMore: Bool {
         return count > (page + 1) * countPerPage
     }
     
     public init() {
         
     }
     
 }
