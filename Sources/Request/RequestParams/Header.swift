//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

public struct HeaderParam: RequestParam {
    var type: RequestParamType = .header
    var key: String?
    var value: Any?
    var children: [RequestParam]? = nil
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// Creates a `HeaderParam` for any number of different headers
public struct Header {
    /// Sets the value for any header
    static func `Any`(key: String, value: String) -> HeaderParam {
        return HeaderParam(key: key, value: value)
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
