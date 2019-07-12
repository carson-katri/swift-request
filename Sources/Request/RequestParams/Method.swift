//
//  Method.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

public enum MethodType: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}

public struct Method: RequestParam {
    var type: RequestParamType = .method
    var key: String?
    var value: Any?
    var children: [RequestParam]? = nil
    
    init(_ type: MethodType) {
        self.value = type
    }
}
