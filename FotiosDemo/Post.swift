//
//  FotiosDemo
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
import Fotios
import CoreData

struct Post {
    
    let id: String
        
    var title = ""
    var body = ""
    
    var userID = ""

    init(id: String) {
        self.id = id
    }
    
}

extension Post: NetworkRequest, NetworkResponse {
    
    typealias NetworkResponse = Post
    typealias NetworkError = FotiosError
    
    init(_ networkBody: Data) throws {
        self.init(id: "")
    }
    
    func networkBody(in environment: NetworkEnvironment) throws -> Data? {
        return nil
    }
        
}

extension Post: Storable, StorageRequest {
    
    typealias StoredObject = CDPost
    typealias Storable = Self
    
    init(_ storedObject: StoredObject) throws {
        self.init(id: storedObject.id.unwrapped(or: ""))
        userID = storedObject.userID.unwrapped(or: "")
        title = storedObject.title.unwrapped(or: "")
        body = storedObject.body.unwrapped(or: "")
    }
    
    func storedObject(byUpdating updatingStoredObject: StoredObject) throws -> StoredObject {
        updatingStoredObject.id = id
        updatingStoredObject.userID = userID
        updatingStoredObject.title = title
        updatingStoredObject.body = body
        return updatingStoredObject
    }
    
    func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = StoredObject.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return fetchRequest
    }
    
}
