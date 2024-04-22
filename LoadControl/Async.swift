//
//  Async.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import Foundation

typealias Async = DispatchQueue

extension Async {
    static func on(queue: DispatchQueue) -> Async {
        return queue
    }
    
    static func immediately(handler: @escaping () -> Void) {
        DispatchQueue.main.async { handler() }
    }
    
    public func immediately(handler: @escaping () -> Void) {
        self.async { handler() }
    }
    
    static func delay(after timeInterval: TimeInterval, handler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: { handler() })
    }
    
    public func delay(after timeInterval: TimeInterval, handler: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + timeInterval, execute: { handler() })
    }
    
    static func delay(_ dispatchTimeInterval: DispatchTimeInterval, handler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval, execute: { handler() })
    }
    
    public func delay(_ dispatchTimeInterval: DispatchTimeInterval, handler: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + dispatchTimeInterval, execute: { handler() })
    }
}
