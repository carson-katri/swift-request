//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

@_functionBuilder
internal struct RequestBuilder {
    static func buildBlock(_ params: RequestParam...) -> RequestParam {
        // Multiple Urls
        if params.filter({ $0.type == .url }).count > 1 {
            fatalError("You cannot specify more than 1 `Url`")
        }
        // Missing Url
        if params.filter({ $0.type == .url }).count < 1 {
            fatalError("You must have a `Url`")
        }
        return CombinedParams(children: params)
    }
}
