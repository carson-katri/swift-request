//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

public extension Timeout {
    struct Source: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let request  = Self(rawValue: 1 << 0)
        public static let resource = Self(rawValue: 1 << 1)

        public static let all: Self = [.request, .resource]
    }
}
