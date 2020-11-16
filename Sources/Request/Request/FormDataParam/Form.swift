//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public struct Form: RequestParam, FormDataParam {
    private let params: [FormDataParam]

    public init(@RequestBuilder params: () -> RequestParam) {
        self.params = params().unzip.map {
            guard
                let formDataParam = $0 as? FormDataParam,
                !(formDataParam is Form)
            else {
                fatalError()
            }

            return formDataParam
        }
    }

    func buildData(_ data: inout Foundation.Data, with boundary: String) {
        params.forEach {
            $0.buildData(&data, with: boundary)
        }
    }
}
