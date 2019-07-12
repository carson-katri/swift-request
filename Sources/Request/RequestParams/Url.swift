//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

public struct Url: RequestParam {
    internal var type: RequestParamType = .url
    internal var key: String? = nil
    var value: Any?
    internal var children: [RequestParam]? = nil
    
    init(_ value: String) {
        self.value = value
    }
}
