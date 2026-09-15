//
//  Copyright (C) 2021 Dmytro Lisitsyn
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

    public func index(offset: Int) -> Int {
        return (offset % count + count) % count
    }

    public subscript(offset offset: Int) -> Element {
        get { return self[index(offset: offset)] }
        set { self[index(offset: offset)] = newValue }
    }

    public mutating func prefetch(expectedCount: Int, makeElement: (_ index: Int) -> Element, deleteElement: (Element) -> Void = { _ in }) {
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

    public subscript(safe index: Int?) -> Element? {
        get {
            if let index, (0..<count).contains(index) {
                return self[index]
            } else {
                return nil
            }
        }
        set(newValue) {
            if let newValue, let index, (0..<count).contains(index) {
                self[index] = newValue
            }
        }
    }

}
