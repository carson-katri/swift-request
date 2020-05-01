//
//  Conformance.swift
//  
//
//  Created by Carson Katri on 8/4/19.
//

import Foundation

extension Json: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        jsonData = value
    }
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        jsonData = value
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        jsonData = value
    }
}

extension Json: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        jsonData = value
    }
}

extension Json: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        jsonData = value
    }
}

extension Json: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        jsonData = value
    }
}

extension Json: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        jsonData = elements
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        jsonData = Dictionary(elements, uniquingKeysWith: { (value1, value2) -> Any in
            return value1
        })
    }
}
