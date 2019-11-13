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

public protocol DeviceOutputLoggerDelegate: AnyObject {
    func logDidChange(in deviceOutputLogger: DeviceOutputLogger)
}

public final class DeviceOutputLogger {
    
    public weak var delegate: DeviceOutputLoggerDelegate?
    
    public private(set) var logString = ""
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        return dateFormatter
    }()
    
    public init() {
        
    }
    
    public func clear() {
        DispatchQueue.main.async {
            self.logString = ""
            
            self.delegate?.logDidChange(in: self)
        }
    }
    
}

extension DeviceOutputLogger: Logger {
    
    public func log(_ event: LoggerEvent) {
        DispatchQueue.main.async {
            if self.logString.count > 50000 {
                self.logString = ""
            }
            
            let timeString = self.dateFormatter.string(from: Date())
            let message = self.makeMessage(describing: event)
            
            let prefix = self.logString.isEmpty ? "" : "\n"
            self.logString += "\(prefix)\(timeString): \(message)"
            
            self.delegate?.logDidChange(in: self)
        }
    }
    
}
