//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

protocol SessionConfiguration: RequestParam {
    func buildConfiguration(_ sessionConfiguration: URLSessionConfiguration)
}

extension SessionConfiguration {
    public func buildParam(_ request: inout URLRequest) {
        fatalError("SessionConfiguration shouldn't build URLRequest")
    }
}
