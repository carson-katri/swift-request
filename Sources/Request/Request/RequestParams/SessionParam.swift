//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

public protocol SessionParam: RequestParam {
    func buildConfiguration(_ configuration: URLSessionConfiguration)
}

extension SessionParam {
    public func buildParam(_ request: inout URLRequest) {}
}
