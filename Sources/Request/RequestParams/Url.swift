//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

/// Sets the URL of the `Request`.
/// - Precondition: Only use one URL in your `Request`. To group or chain requests, use a `RequestGroup` or `RequestChain`.
public struct Url: RequestParam {
    internal var type: RequestParamType = .url
    internal var key: String? = nil
    var value: Any?
    internal var children: [RequestParam]? = nil
    
    init(_ value: String) {
        self.value = value
    }
}
