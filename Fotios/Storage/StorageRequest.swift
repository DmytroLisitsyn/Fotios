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
import CoreData

// MARK: StorageRequest

public protocol AnyStorageRequest {
    
    func fetchRequest() -> NSFetchRequest<NSFetchRequestResult>

}

public protocol StorageRequest: AnyStorageRequest {
    
    associatedtype Storable: Fotios.Storable
        
}

// MARK: Storable

public protocol Storable {
    
    associatedtype StoredObject: NSManagedObject
    
    init(storedObject: StoredObject) throws

    @discardableResult
    func storedObject(byUpdating storedObject: StoredObject) throws -> StoredObject

}

extension Storable {

    @discardableResult
    public func storedObject(in context: NSManagedObjectContext) throws -> StoredObject {
        let storedObject = StoredObject(context: context)
        return try self.storedObject(byUpdating: storedObject)
    }
    
    @discardableResult
    public func storedObject(in context: NSManagedObjectContext?) throws -> StoredObject? {
        guard let context = context else {
            return nil
        }
        
        let storedObject = StoredObject(context: context)
        return try self.storedObject(byUpdating: storedObject)
    }

}

// MARK: StoredObjectPrimaryKey

public protocol StoredObjectPrimaryKey {
    static var storedObjectPrimaryKey: String { get }
}
