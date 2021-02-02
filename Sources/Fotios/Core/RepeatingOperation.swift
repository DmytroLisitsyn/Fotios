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
