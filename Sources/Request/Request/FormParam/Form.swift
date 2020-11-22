//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public struct Form: FormParam {
    private let rootParam: FormParam

    public init(@FormBuilder params: () -> FormParam) {
        self.rootParam = params()
    }

    public func buildData(_ data: inout Foundation.Data, with boundary: String) {
        if rootParam is EmptyParam {
            return
        }

        rootParam.buildData(&data, with: boundary)
    }
}
