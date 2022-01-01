//
//  File.swift
//
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

/// Creates a `HeaderParam` for any number of different headers
public struct Header {
    /// Sets the value for any header
    public struct `Any`: RequestParam {
        private let key: String
        private let value: String?

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }

        public func buildParam(_ request: inout URLRequest) {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}

//@resultBuilder
//struct HeadersBuilder {
//    static func buildBlock(_ headers: HeaderParam...) -> RequestParam {
//        return CombinedParams(children: headers)
//    }
//}
//
//
//struct Headers: RequestParam {
//    var type: RequestParamType = .header
//    var key: String? = nil
//    var value: Any? = nil
//    var children: [RequestParam]?
//
//    init(@HeadersBuilder builder: () -> RequestParam) {
//        self.children = builder().children
//    }
//}
