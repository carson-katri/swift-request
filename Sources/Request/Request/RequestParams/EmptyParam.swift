//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public struct EmptyParam: RequestParam {
    public func buildParam(_ request: inout URLRequest) {}
}

extension EmptyParam: FormParam {
    public func buildData(_ data: inout Data, with boundary: String) {}
}
