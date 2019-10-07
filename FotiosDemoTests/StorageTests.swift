//
//  FotiosDemoTests
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

import XCTest
import Fotios
@testable import FotiosDemo

final class StorageTests: XCTestCase {

    var storage: Storage!
    
    override func setUp() {
        let model = Storage.dataModel(named: "Model.momd")
        storage = Storage(model: model, shouldUseInMemoryStorage: false)
    }
    
    func testPostSavingAndFetchingByID() {
        do {
            try storage.save([Post.post1, Post.post2])

            let entity = try storage.fetchFirst(Post.post1)
            
            XCTAssertEqual(Post.post1.id, entity?.id)
            XCTAssertEqual(Post.post1.userID, entity?.userID)
            XCTAssertEqual(Post.post1.title, entity?.title)
            XCTAssertEqual(Post.post1.body, entity?.body)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPostSavingAndFetchingAndDeletingByID() {
        do {
            try storage.save([Post.post1, Post.post2])
            
            let entity = try storage.fetchFirst(Post.post1)
            
            XCTAssert(entity != nil)
            
            try storage.delete(Post.post1)
            
            let deletedEntity = try storage.fetchFirst(Post.post1)

            XCTAssert(deletedEntity == nil)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
}

extension Post {
        
    static var post1: Post {
        var entity = Post(id: "1")
        entity.userID = "1"
        entity.title = "Title 1"
        entity.body = "Body 1"
        return entity
    }
    
    static var post2: Post {
        var entity = Post(id: "2")
        entity.userID = "2"
        entity.title = "Title 2"
        entity.body = "Body 2"
        return entity
    }
    
}
