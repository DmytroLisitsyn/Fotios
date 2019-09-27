//
//  ObserverContainer.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
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
