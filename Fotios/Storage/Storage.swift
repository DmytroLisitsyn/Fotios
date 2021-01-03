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
    
    private let account: String
    private let model: NSManagedObjectModel
    private let persistentContainer: NSPersistentContainer

    public init(account: String = "X-Storage-X", model: NSManagedObjectModel, shouldUseInMemoryStorage: Bool = false, persistentStoresLoadingHandler: @escaping ((NSPersistentStoreDescription, Error?) -> Void) = persistentStoresLoadingHandler) {
        self.account = account
        self.model = model
        
        persistentContainer = NSPersistentContainer(name: account, managedObjectModel: model)
        
        if shouldUseInMemoryStorage {
            let storeDescription = NSPersistentStoreDescription()
            storeDescription.shouldAddStoreAsynchronously = false
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.type = NSInMemoryStoreType
            
            persistentContainer.persistentStoreDescriptions = [storeDescription]
        }
        
        persistentContainer.loadPersistentStores(completionHandler: persistentStoresLoadingHandler)
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    public func save<T: Storable>(_ entity: T, completionHandler: Closure<PlainResult>?) {
        save([entity], completionHandler: completionHandler)
    }
    
    public func save<T: Storable>(_ entities: [T], completionHandler: Closure<PlainResult>?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            do {
                for entity in entities {
                    if let request = entity as? AnyStorageRequest, let storedObject = try context.fetch(request.storageRequest()).first as? T.StoredObject {
                        try entity.storedObject(byUpdating: storedObject)
                    } else {
                        try entity.storedObject(in: context)
                    }
                }
                
                if context.hasChanges {
                    try context.save()
                    context.reset()
                }
                
                completionHandler?(.success(()))
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
    }

    public func fetchFirst<T: StorageRequest>(_ request: T, completionHandler: Closure<TypedResult<T.Storable?>>?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            do {
                let fetchRequest = request.storageRequest()
                fetchRequest.fetchLimit = 1
                
                let storedObject = try context.fetch(fetchRequest).first as? T.Storable.StoredObject
                let entity = try storedObject.map(T.Storable.init)
                
                completionHandler?(.success(entity))
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func fetch<T: StorageRequest>(_ request: T, completionHandler: Closure<TypedResult<[T.Storable]>>?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            do {
                let storedObjects = try context.fetch(request.storageRequest()) as! [T.Storable.StoredObject]
                let entities = try storedObjects.map(T.Storable.init)

                completionHandler?(.success(entities))
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
    }

    public func delete<T: StorageRequest>(_ request: T, completionHandler: Closure<PlainResult>?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            do {
                let storedObjects = try context.fetch(request.storageRequest()) as! [T.Storable.StoredObject]
                storedObjects.forEach(context.delete)
                
                if context.hasChanges {
                    try context.save()
                    context.reset()
                }

                completionHandler?(.success(()))
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
    }
    
    public func deleteAll(completionHandler: Closure<PlainResult>?) {
        let context = persistentContainer.newBackgroundContext()
        
        context.perform {
            do {
                for entityDescription in self.model.entities {
                    guard let entityName = entityDescription.name else { continue }
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let storedObjects = try context.fetch(fetchRequest) as! [NSManagedObject]
                    storedObjects.forEach(context.delete)
                }
                
                if context.hasChanges {
                    try context.save()
                    context.reset()
                }

                completionHandler?(.success(()))
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
    }

}

extension Storage {
    
    public static func storedObjectModel(named name: String, in bundle: Bundle = .main) -> NSManagedObjectModel {
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
