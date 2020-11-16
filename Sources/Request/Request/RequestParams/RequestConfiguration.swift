//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

public protocol SessionParam: RequestParam {
    func buildConfiguration(_ sessionConfiguration: URLSessionConfiguration)
}

extension SessionParam {
    public func buildParam(_ request: inout URLRequest) {
        fatalError("SessionConfiguration shouldn't build URLRequest")
    }
}
