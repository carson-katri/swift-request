//
//  Body.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

public struct Body: RequestParam {
    var type: RequestParamType = .body
    var key: String?
    var value: Any?
    var children: [RequestParam]?
    
    init(_ dict: [String:Any]) {
        self.value = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    init(_ string: String) {
        self.value = string.data(using: .utf8)
    }
}
