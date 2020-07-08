//
//  File.swift
//  
//
//  Created by Carson Katri on 6/23/20.
//

import Foundation

/// Sets the `timeoutIntervalForRequest` and/or `timeoutIntervalForResource` of the `Request`
public struct Timeout: RequestParam {
    public var type: RequestParamType = .timeout
    public var value: Any? = nil
    
    public init(_ timeout: TimeInterval, for source: Source = .all) {
        self.value = (source, timeout)
    }
    
    public struct Source: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let request  = Self(rawValue: 1 << 0)
        public static let resource = Self(rawValue: 1 << 1)

        public static let all: Self = [.request, .resource]
    }
}
