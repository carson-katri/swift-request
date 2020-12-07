//
//  Method.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

/// The method of the HTTP request, such as `GET` or `POST`
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

/// Sets the method of the `Request`
public struct Method: RequestParam {
    public var type: MethodType?
    
    public init(_ type: MethodType) {
        self.type = type
    }

    public func buildParam(_ request: inout URLRequest) {
        request.httpMethod = type?.rawValue
    }
}
