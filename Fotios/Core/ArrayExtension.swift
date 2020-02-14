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

extension Array {
    
    public func element(at index: Int?) -> Element? {
        if let index = index, (0..<count).contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
    
    /// Page index starts from 0.
    public func elements(atPage page: Int, perPage: Int) -> Array {
        let lowerBound = page * perPage
        let upperBound = lowerBound + perPage
        
        if lowerBound > count {
            return []
        } else if upperBound > count {
            return Array(self[lowerBound..<count])
        } else {
            return Array(self[lowerBound..<upperBound])
        }
    }
    
    public func index(offset: Int) -> Int {
        let index = (offset % count + count) % count
        return index
    }
    
    public subscript(offset offset: Int) -> Element {
        get {
            return self[index(offset: offset)]
        }
        set(newValue) {
            self[index(offset: offset)] = newValue
        }
    }
    
    public mutating func prefetchArray(expectedCount: Int, makeElement: (_ index: Int) -> Element, deleteElement: (Element) -> Void = { _ in }) {
        let diff = count - expectedCount
        if diff < 0 {
            var newElements = Self.init()
            
            for index in 0..<abs(diff) {
                let element = makeElement(index + count)
                newElements.append(element)
            }
            
            append(contentsOf: newElements)
        } else if diff > 0 {
            let toRemove = suffix(diff)
            toRemove.forEach(deleteElement)
            removeLast(diff)
        }
    }

}
