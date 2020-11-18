//
//  File.swift
//  
//
//  Created by brennobemoura on 18/11/20.
//

import Foundation

@_functionBuilder
public struct FormBuilder {
    public static func buildBlock(_ params: FormParam...) -> FormParam {
        Combined(params)
    }

    public static func buildBlock(_ param: FormParam) -> FormParam {
        param
    }

    public static func buildBlock() -> EmptyParam {
        EmptyParam()
    }

    public static func buildIf(_ param: FormParam?) -> FormParam {
        EmptyParam()
    }

    public static func buildEither(first: FormParam) -> FormParam {
        first
    }

    public static func buildEither(second: FormParam) -> FormParam {
        second
    }
}

private extension FormBuilder {
    struct Combined: FormParam {
        let children: [FormParam]

        init(_ children: [FormParam]) {
            self.children = children
        }

        func buildData(_ data: inout Data, with boundary: String) {
            fatalError()
        }
    }
}

private extension FormBuilder {
    struct Empty: FormParam {
        func buildData(_ data: inout Data, with boundary: String) {}
    }
}

extension FormParam {
    var unzip: [FormParam] {
        (self as? FormBuilder.Combined).map {
            $0.children
                .reduce([]) { $0 + $1.unzip }
        } ?? [self]
    }
}
