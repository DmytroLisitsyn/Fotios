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
import RealmSwift

public final class Storage {
    
    public let account: String?
    
    /// - Note: Keep value up to date with Realm entities changes.
    ///
    /// See [docs](https://realm.io/docs/swift/latest/#performing-a-migration) for details.
    private let schemaVersion: UInt64 = 0
        
    private var configuration: Realm.Configuration!
    
    /// - Attention: Set `shouldResetStorageIfMigrationNeeded` to `false` before release. Consider writing storages migrator, that will run before any dependency configuration.
    public init(account: String?, encryptionKey: Data? = nil, shouldUseInMemoryStorage: Bool = false, shouldResetStorageIfMigrationNeeded: Bool = true, migrationBlock: RealmSwift.MigrationBlock? = nil) {
        self.account = account
        
        configuration = Realm.Configuration(encryptionKey: encryptionKey, schemaVersion: schemaVersion, migrationBlock: migrationBlock)
        
        let database = account ?? "Default"
        configuration.fileURL = configuration.fileURL!.deletingLastPathComponent().appendingPathComponent("\(database).realm")
        
        configuration.deleteRealmIfMigrationNeeded = shouldResetStorageIfMigrationNeeded
        
        if shouldUseInMemoryStorage {
            configuration.inMemoryIdentifier = UUID().uuidString
        }
    }
    
    public func migrateIfNeeded(completionHandler: () -> Void) {
        _ = try! Realm(configuration: configuration)
        
        completionHandler()
    }
    
}

extension Storage {
    
    public func save<T: Storable>(_ entity: T) throws {
        try save([entity])
    }
    
    public func save<T: Storable>(_ entities: [T]) throws {
        let realm = try Realm(configuration: configuration)
        
        try realm.write {
            let storedObjects = try entities.map { try $0.storedObject(in: realm) }
            realm.add(storedObjects)
        }
    }
    
    public func fetchFirst<T: StorageRequest>(_ request: T) throws -> T.Storable? {
        let realm = try Realm(configuration: configuration)
        let rlmList = try fetch(request, realm: realm)

        let entity = try rlmList.first.flatMap(T.Storable.init)
        return entity
    }

    public func fetch<T: StorageRequest>(_ request: T) throws -> [T.Storable] {
        let realm = try Realm(configuration: configuration)
        let rlmList = try fetch(request, realm: realm)

        let entities = try rlmList.map(T.Storable.init)
        return entities
    }

    public func count<T: StorageRequest>(_ request: T) throws -> Int {
        let realm = try Realm(configuration: configuration)
        let rlmList = try fetch(request, realm: realm)
        return rlmList.count
    }

    public func delete<T: StorageRequest>(_ request: T) throws {
        let realm = try Realm(configuration: configuration)
        let rlmList = try fetch(request, realm: realm)

        try realm.write {
            realm.delete(rlmList)
        }
    }
    
    public func purge() throws {
        let realmURL = configuration.fileURL!
        let realmURLs = [realmURL, realmURL.appendingPathExtension("lock"), realmURL.appendingPathExtension("note"), realmURL.appendingPathExtension("management")]
        
        for URL in realmURLs {
            try FileManager.default.removeItem(at: URL)
        }
    }
    
}

extension Storage {
    
    private func fetch<T: StorageRequest>(_ request: T, realm: Realm) throws -> Results<T.Storable.StoredObject> {
        var result = realm.objects(T.Storable.StoredObject.self)
        
        if let query = request.filter() {
            result = result.filter(query)
        }
        
        if let pagination = request.pagination() {
            let lowerBound = pagination.page * pagination.entitiesPerPage
            let upperBound = lowerBound + pagination.entitiesPerPage
            
            if lowerBound > result.count {
                _ = result.dropLast(result.count)
            } else if upperBound > result.count {
                result = result[lowerBound..<result.count].base
            } else {
                result = result[lowerBound..<upperBound].base
            }
        }

        return result
    }

//    private var encryptionKey: Data {
//        let key: Data
//
//        if let storedKey = try? keychain.fetch(.storageEncryptionKey) {
//            key = storedKey
//        } else {
//            key = .makeRandomSecureBytes(count: 64)
//            try? keychain.save(key, as: .storageEncryptionKey)
//        }
//
//        return key
//    }

}
