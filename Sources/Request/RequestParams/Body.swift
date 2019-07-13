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
public struct Body: RequestParam {
    var type: RequestParamType = .body
    var key: String?
    var value: Any?
    var children: [RequestParam]?
    
    /// Creates the `Body` from key-value pairs
    init(_ dict: [String:Any]) {
        self.value = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    /// Creates the `Body` from a `String`
    init(_ string: String) {
        self.value = string.data(using: .utf8)
    }
}
