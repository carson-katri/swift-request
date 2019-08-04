//
//  Subscripts.swift
//  
//
//  Created by Carson Katri on 8/4/19.
//

import Foundation

public enum JsonSubscriptType {
    case key(_ s: String)
    case index(_ i: Int)
}

public protocol JsonSubscript {
    var jsonKey: JsonSubscriptType { get }
}

extension String: JsonSubscript {
    public var jsonKey: JsonSubscriptType {
        .key(self)
    }
}

extension Int: JsonSubscript {
    public var jsonKey: JsonSubscriptType {
        .index(self)
    }
}
