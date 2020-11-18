//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public struct Form: FormParam {
    private let params: [FormParam]

    public init(@FormBuilder params: () -> FormParam) {
        self.params = params().unzip
    }

    public func buildData(_ data: inout Foundation.Data, with boundary: String) {
        params.dropLast().forEach {
            $0.buildData(&data, with: boundary)
            data.append(middle)
        }

        params.last?.buildData(&data, with: boundary)
    }
}
