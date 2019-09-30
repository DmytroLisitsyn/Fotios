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

public protocol ObserverContainable: AnyObject {
    
    associatedtype Observer
    
    var observers: ObserverContainer<Observer> { get set }
    
}

extension ObserverContainable {
    
    public func addObserver(_ observer: Observer) {
        observers.insert(observer)
    }
    
    public func removeObserver(_ observer: Observer) {
        observers.remove(observer)
    }
    
}

public struct ObserverContainer<Observer> {
    
    public var count: Int {
        return containers.count
    }
    
    public var isEmpty: Bool {
        return containers.isEmpty
    }
    
    private var containers: Set<_Container> = []
    
    public init() {
        
    }
    
    public mutating func insert(_ observer: Observer) {
        let anyObserver = observer as AnyObject
        let container = _Container(anyObserver)
        containers.update(with: container)
        
        purgeEmptyContainers()
    }
    
    public mutating func remove(_ observer: Observer) {
        let anyObserver = observer as AnyObject
        let container = containers.first(where: { $0.identifier == ObjectIdentifier(anyObserver) })
        
        if let container = container {
            containers.remove(container)
        }
        
        purgeEmptyContainers()
    }
    
    public func enumerateObservers(_ body: (_ observer: Observer) -> Void) {
        containers.forEach { container in
            if let observer = container.observer as? Observer {
                body(observer)
            }
        }
    }
    
    private mutating func purgeEmptyContainers() {
        containers = containers.filter({ $0.observer is Observer })
    }
    
}

private struct _Container: Hashable {
    
    private(set) weak var observer: AnyObject?
    
    let identifier: ObjectIdentifier
    
    init(_ observer: AnyObject) {
        self.observer = observer
        self.identifier = ObjectIdentifier(observer)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
