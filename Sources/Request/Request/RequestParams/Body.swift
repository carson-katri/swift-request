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
    public var type: RequestParamType = .body
    public var value: Any?
    
    /// Creates the `Body` from key-value pairs
    public init(_ dict: [String:Any]) {
        self.value = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    /// Creates the `Body` from an `Encodable` type using `JSONEncoder`
    public init<T: Encodable>(_ value: T) {
        self.value = try? JSONEncoder().encode(value)
    }
    
    /// Creates the `Body` from a `String`
    public init(_ string: String) {
        self.value = string.data(using: .utf8)
    }
}

#if canImport(SwiftUI)
public typealias RequestBody = Body
#endif
