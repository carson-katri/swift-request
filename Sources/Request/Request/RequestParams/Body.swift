//
//  Body.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

/// Sets the body of the `Request`
///
/// Expressed as key-value pairs:
///
///     Request {
///         Url("api.example.com/save")
///         Body([
///             "doneWorking": true
///         ])
///     }
///
/// Or as a `String`:
///
///     Request {
///         Url("api.example.com/save")
///         Body("myData")
///     }
///
/// Or as an `Encodable` type:
///
///     Request {
///         Url("api.example.com/save")
///         Body(codableTodo)
///     }
///
public struct Body: RequestParam {
    private let data: Data?
    
    /// Creates the `Body` from key-value pairs
    public init(_ dict: [String:Any]) {
        self.data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    /// Creates the `Body` from an `Encodable` type using `JSONEncoder`
    public init<T: Encodable>(_ value: T) {
        self.data = try? JSONEncoder().encode(value)
    }
    
    /// Creates the `Body` from a `String`
    public init(_ string: String) {
        self.data = string.data(using: .utf8)
    }

    public func buildParam(_ request: inout URLRequest) {
        request.httpBody = data
    }
}

#if canImport(SwiftUI)
public typealias RequestBody = Body
#endif
