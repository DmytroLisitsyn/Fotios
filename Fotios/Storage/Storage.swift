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

public final class Storage {
    
    public let account: String?
    
    private let persistentContainer: NSPersistentContainer

    public init(account: String = "Storage", model: NSManagedObjectModel, shouldUseInMemoryStorage: Bool = false, persistentStoresLoadingHandler: @escaping ((NSPersistentStoreDescription, Error?) -> Void) = persistentStoresLoadingHandler) {
        self.account = account
        
        persistentContainer = NSPersistentContainer(name: account, managedObjectModel: model)
        
        if shouldUseInMemoryStorage {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores(completionHandler: persistentStoresLoadingHandler)
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public func save<T: Storable>(_ entity: T) throws {
        try save([entity])
    }
    
    public func save<T: Storable>(_ entities: [T]) throws {
        try performAndWait { context in
            for entity in entities {
                if let request = entity as? AnyStorageRequest, let storedObject = try context.fetch(request.fetchRequest()).first as? T.StoredObject {
                    try entity.storedObject(byUpdating: storedObject)
                } else {
                    try entity.storedObject(in: context)
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func fetchFirst<T: StorageRequest>(_ request: T) throws -> T.Storable? {
        return try performAndWait { context -> T.Storable? in
            let fetchRequest = request.fetchRequest()
            fetchRequest.fetchLimit = 1
            
            let storedObject = try context.fetch(fetchRequest).first as? T.Storable.StoredObject
            let entity = try storedObject.map(T.Storable.init)
            return entity
        }
    }
    
    public func fetch<T: StorageRequest>(_ request: T) throws -> [T.Storable] {
        return try performAndWait { context -> [T.Storable] in
            let storedObjects = try context.fetch(request.fetchRequest()) as! [T.Storable.StoredObject]
            let entities = try storedObjects.map(T.Storable.init)
            return entities
        }
    }

    public func delete<T: StorageRequest>(_ request: T) throws {
        try performAndWait { context in
            let storedObjects = try context.fetch(request.fetchRequest()) as! [T.Storable.StoredObject]
            storedObjects.forEach(context.delete)
            
            if context.hasChanges {
                try context.save()
            }
        }
    }

}

extension Storage {
    
    public static func dataModel(named name: String, in bundle: Bundle = .main) -> NSManagedObjectModel {
        let modelURL = bundle.url(forResource: name, withExtension: nil)!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        return model
    }
    
}

extension Storage {

    public static var persistentStoresLoadingHandler: ((NSPersistentStoreDescription, Error?) -> Void) {
        return { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

}

extension Storage {
    
    private final class PerformAndWaitResultContainer<T> {
        var value: T?
    }
    
    private func performAndWait<T>(_ block: (_ context: NSManagedObjectContext) throws -> T) throws -> T {
        let container = PerformAndWaitResultContainer<T>()
        let context = persistentContainer.newBackgroundContext()
        
        var error: Error?
                
        context.performAndWait {
            do {
                container.value = try block(context)
            } catch let catchedError {
                error = catchedError
            }
        }
        
        try error.map { throw $0 }
        
        return container.value!
    }
    
}
