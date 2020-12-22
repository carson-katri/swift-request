//
//  FormBuilder.Combined.swift
//  
//
//  Created by brennobemoura on 22/11/20.
//

import Foundation

internal extension FormBuilder {
    struct Combined: FormParam {
        let children: [FormParam]

        init(_ children: [FormParam]) {
            self.children = children
        }

        func buildData(_ data: inout Data, with boundary: String) {
            children.dropLast().forEach {
                $0.buildData(&data, with: boundary)
                data.append(middle)
            }

            children.last?.buildData(&data, with: boundary)
        }
    }
}
