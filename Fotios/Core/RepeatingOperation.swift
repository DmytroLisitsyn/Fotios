//
//  RepeatingOperation.swift
//  Fotios
//
//  Created by Dmytro Lisitsyn on 9/27/19.
//  Copyright © 2019 Dmytro Lisitsyn. All rights reserved.
//

import Foundation

public final class RepeatingOperation {
    
    private let label: String
    private let interval: DispatchTimeInterval
    private let qos: DispatchQoS
    
    private var queue: DispatchQueue?
    private var workItem: DispatchWorkItem?
    
    public init(label: String, interval: TimeInterval, qos: DispatchQoS = .background) {
        self.label = label
        self.interval = .seconds(Int(interval))
        self.qos = qos
    }
    
    deinit {
        stop()
    }
    
    public func start(_ operation: @escaping (_ completionHandler: @escaping () -> Void) -> Void) {
        if queue == nil {
            queue = DispatchQueue(label: label, qos: qos)
        }
        
        workItem?.cancel()
        workItem = DispatchWorkItem(flags: .inheritQoS) { [weak self] in
            guard let strongSelf = self else { return }
            
            operation {
                strongSelf.start(operation)
            }
        }
        
        let deadline: DispatchTime = .now() + interval
        queue?.asyncAfter(deadline: deadline, execute: workItem!)
    }
    
    public func stop() {
        workItem?.cancel()
        workItem = nil
        
        queue = nil
    }
    
}
