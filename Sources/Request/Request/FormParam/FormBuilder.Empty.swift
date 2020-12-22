//
//  FormBuilder.Empty.swift
//  
//
//  Created by brennobemoura on 22/11/20.
//

import Foundation

internal extension FormBuilder {
    struct Empty: FormParam {
        func buildData(_ data: inout Data, with boundary: String) {}
    }
}
