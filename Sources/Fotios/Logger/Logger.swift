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

public enum LoggerEvent {
    
    case info(String)
    
    case event(String)

    case success(String)
    
    /// In `source` provide description of the failed action in present tense. For example "Authorize with session token".
    case failure(source: String, error: Error)
    
}

public protocol Logger: AnyObject {
    
    func log(_ event: LoggerEvent)
    func log(_ message: String)
    
}

extension Logger {
    
    public func log(_ event: LoggerEvent) {
        log(makeMessage(describing: event))
    }
    
    func makeMessage(describing event: LoggerEvent) -> String {
        switch event {
        case .info(let message):
            return "ℹ️ \(message)"
        case .event(let message):
            return "✴️ \(message)"
        case .success(let message):
            return "✅ \(message)"
        case .failure(let source, let error):
            var source = source
            
            if !source.isEmpty {
                let first = Character("\(source.first!)".lowercased())
                source.removeFirst()
                source.insert(first, at: source.startIndex)
            }
            
            var errorString = "\(error)"
            
            if let localizedError = error as? LocalizedError {
                errorString = localizedError.errorDescription ?? localizedError.localizedDescription
            }
            
            return "🛑 Error when \(source): \(errorString)"
        }
    }
    
}
