//
//  Query.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

public struct QueryParam: RequestParam {
    var type: RequestParamType = .query
    var key: String?
    var value: Any?
    var children: [RequestParam]?
    
    init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct Query: RequestParam {
    var type: RequestParamType = .query
    var key: String?
    var value: Any?
    var children: [RequestParam]? = []
    
    init(_ params: [String:String]) {
        Array(params.keys).forEach { key in
            self.children?.append(QueryParam(key, value: params[key]!))
        }
    }
    
    init(_ params: [QueryParam]) {
        self.children = params
    }
}
