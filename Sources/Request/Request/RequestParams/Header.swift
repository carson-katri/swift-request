//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

public struct HeaderParam: RequestParam {
    public var type: RequestParamType = .header
    public var key: String?
    public var value: Any?
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Creates a `HeaderParam` for any number of different headers
public struct Header {
    /// Sets the value for any header
    public static func `Any`(key: String, value: String) -> HeaderParam {
        HeaderParam(key: key, value: value)
    }
}

//@_functionBuilder
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
