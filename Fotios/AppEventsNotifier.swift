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

// MARK: AppEventsObserver

public protocol AppEventsObserver: AnyObject {
    func appDidEnterBackground(_ appEventsNotifier: AppEventsNotifier)
    func appWillEnterForeground(_ appEventsNotifier: AppEventsNotifier)
}

extension AppEventsObserver {
    public func appDidEnterBackground(_ appEventsNotifier: AppEventsNotifier) { }
    public func appWillEnterForeground(_ appEventsNotifier: AppEventsNotifier) { }
}

// MARK: AppEventsNotifier

public final class AppEventsNotifier {
    
    private var observers = ObserverContainer<AppEventsObserver>()
    
    public init() {
        
    }
    
    public func addObserver(_ observer: AppEventsObserver) {
        observers.insert(observer)
    }
    
    public func removeObserver(_ observer: AppEventsObserver) {
        observers.remove(observer)
    }
    
    public func notifyAppEnteredBackground() {
        observers.enumerateObservers { observer in
            observer.appDidEnterBackground(self)
        }
    }
    
    public func notifyAppAboutToEnterForeground() {
        observers.enumerateObservers { observer in
            observer.appWillEnterForeground(self)
        }
    }
    
}
