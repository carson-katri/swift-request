//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

/// The type of `RequestParam`, used by the `Request` to form the `URLRequest`
enum RequestParamType {
    case url
    case method
    case query
    case body
    case header
    case combined
}

internal protocol RequestParam {
    var type: RequestParamType { get }
    var key: String? { get }
    var value: Any? { get set }
    var children: [RequestParam]? { get }
}

/// A way to create a custom `RequestParam`
/// - Important: You will most likely want to use one of the builtin `RequestParam`s, such as: `Url`, `Method`, `Header`, `Query`, or `Body`.
public struct AnyParam: RequestParam {
    var type: RequestParamType
    var key: String?
    var value: Any?
    var children: [RequestParam]?
}

internal struct CombinedParams: RequestParam {
    var type: RequestParamType = .combined
    var key: String? = nil
    var value: Any? = nil
    var children: [RequestParam]?
    
    init(children: [RequestParam]) {
        self.children = children
    }
}
