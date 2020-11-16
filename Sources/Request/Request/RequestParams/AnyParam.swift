//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

/// A way to create a custom `RequestParam`
/// - Important: You will most likely want to use one of the builtin `RequestParam`s, such as: `Url`, `Method`, `Header`, `Query`, or `Body`.
@available(*, deprecated, message: "`AnyParam` is deprecated. Please conform to the `RequestParam` protocol instead.")
public struct AnyParam: RequestParam {
    private let requestParam: RequestParam

    public init<Param>(_ requestParam: Param) where Param: RequestParam {
        self.requestParam = requestParam
    }

    public func buildParam(_ request: inout URLRequest) {
        requestParam.buildParam(&request)
    }
}
