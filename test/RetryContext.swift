//
//  RetryContext.swift
//  test_Example
//
//  Created by 张梦磊 on 2022/1/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

public struct ErrorRetryContext {
    
    public let error: Error
    
    public var retriedCount: Int
    
    public let userInfo: Any?
    
    init(error: Error, userInfo: Any? = nil) {
        self.error = error
        self.userInfo = userInfo
        self.retriedCount = 0
    }

    @discardableResult
    mutating func increaseRetryCount() -> ErrorRetryContext {
        retriedCount += 1
        return self
    }
}

public enum RetryError: Error {
    case maxCount
}

public enum RetryResult {
    case retry(userInfo: Any?)
    case stop
}

public struct DelayRetry {
    
    public enum Interval {
        /// The next retry attempt should happen in fixed seconds. For example, if the associated value is 3, the
        /// attempts happens after 3 seconds after the previous decision is made.
        case seconds(TimeInterval)
        /// The next retry attempt should happen in an accumulated duration. For example, if the associated value is 3,
        /// the attempts happens with interval of 3, 6, 9, 12, ... seconds.
        case accumulated(TimeInterval)
        /// Uses a block to determine the next interval. The current retry count is given as a parameter.
        case custom(block: (_ retriedCount: Int) -> TimeInterval)

        func timeInterval(for retriedCount: Int) -> TimeInterval {
            let retryAfter: TimeInterval
            switch self {
            case .seconds(let interval):
                retryAfter = interval
            case .accumulated(let interval):
                retryAfter = Double(retriedCount + 1) * interval
            case .custom(let block):
                retryAfter = block(retriedCount)
            }
            return retryAfter
        }
    }
    
    public let maxRetryCount: Int
    
    public let retryInterval: Interval
    
    public init(maxRetryCount: Int, retryInterval: Interval = .seconds(3)) {
        self.maxRetryCount = maxRetryCount
        self.retryInterval = retryInterval
    }
    
    public func retry(context: ErrorRetryContext, retryHandler: @escaping (RetryResult) -> Void) {
        // Retry count exceeded.
        guard context.retriedCount < maxRetryCount else {
            retryHandler(.stop)
            return
        }


        let interval = retryInterval.timeInterval(for: context.retriedCount)
        if interval == 0 {
            retryHandler(.retry(userInfo: nil))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                retryHandler(.retry(userInfo: nil))
            }
        }
    }
}


//var retryContext: ErrorRetryContext?
//let retryStrategy = DelayRetry(maxRetryCount: 3, retryInterval: .seconds(0))

//error

//let context = retryContext?.increaseRetryCount() ?? RetryContext(source: source, error: error)
//retryContext = context
//
//retryStrategy.retry(context: context) { decision in
//    switch decision {
//    case .retry(let userInfo):
//        retryContext?.userInfo = userInfo
//        retryFunction()
//    case .stop:
//        fileFunction()
//    }
//}
