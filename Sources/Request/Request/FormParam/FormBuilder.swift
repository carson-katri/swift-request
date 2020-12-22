//
//  FormBuilder.swift
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
        param ?? EmptyParam()
    }

    public static func buildEither(first: FormParam) -> FormParam {
        first
    }

    public static func buildEither(second: FormParam) -> FormParam {
        second
    }
}
