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
