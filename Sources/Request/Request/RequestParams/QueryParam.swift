//
//  Query.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

/// A key-value pair for a part of the query string
public struct QueryParam: RequestParam {
    public var type: RequestParamType = .query
    public var key: String?
    public var value: Any?
    public var children: [RequestParam]?
    
    public init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Sets the query string of the `Request`
///
/// `[key:value, key2:value2]` becomes `?key=value&key2=value2`
public struct Query: RequestParam {
    public var type: RequestParamType = .query
    public var key: String?
    public var value: Any?
    public var children: [RequestParam]? = []
    
    /// Creates the `Query` from `[key:value]` pairs
    /// - Parameter params: Key-value pairs describing the `Query`
    public init(_ params: [String:String]) {
        Array(params.keys).forEach { key in
            self.children?.append(QueryParam(key, value: params[key]!))
        }
    }
    
    /// Creates the `Query` directly from an array of `QueryParam`s
    public init(_ params: [QueryParam]) {
        self.children = params
    }
}
