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

    public private(set) var logString = "" {
        didSet { didSetLogString(logString) }
    }
    
    public var logStringCountLimit = 10000

    private let dateFormatter = DateFormatter()
    private let fileURL: URL?
    private let queue = DispatchQueue(label: "DeviceOutputLogger")

    public init(filename: String = "device_output_log.txt") {
        dateFormatter.dateFormat = "HH:mm:ss.SSS"

        let fileManager = FileManager.default
        
        fileURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
        
        if let fileURL = fileURL {
            logString = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
        }
    }
    
    public func clear() {
        queue.sync {
            self.logString = ""

            DispatchQueue.main.async {
                self.delegate?.logDidChange(in: self)
            }
        }
    }

    private func didSetLogString(_ logString: String) {
        if let fileURL = fileURL {
            try? logString.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
}

extension DeviceOutputLogger: Logger {
    
    public func log(_ event: LoggerEvent) {
        queue.sync {
            let shouldDeleteOldest = self.logString.count > logStringCountLimit
            
            let timeString = self.dateFormatter.string(from: Date())
            let message = self.makeMessage(describing: event)
            let prefix = self.logString.isEmpty ? "" : "\n"
            let line = "\(prefix)\(timeString): \(message)"
            
            if shouldDeleteOldest {
                if self.logString.count > line.count {
                    self.logString.removeFirst(line.count)
                } else {
                    self.logString.removeAll()
                }
            }
            
            self.logString += line

            DispatchQueue.main.async {
                self.delegate?.logDidChange(in: self)
            }
        }
    }
    
}
