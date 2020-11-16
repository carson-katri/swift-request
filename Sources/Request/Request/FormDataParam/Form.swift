//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public struct Form: FormParam {
    private let params: [FormParam]

    public init(@RequestBuilder params: () -> RequestParam) {
        self.params = params().unzip.map {
            guard
                let FormParam = $0 as? FormParam,
                !(FormParam is Form)
            else {
                fatalError()
            }

            return FormParam
        }
    }

    public func buildData(_ data: inout Foundation.Data, with boundary: String) {
        params.forEach {
            $0.buildData(&data, with: boundary)
        }
    }
}
