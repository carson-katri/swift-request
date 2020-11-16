//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

internal struct CombinedParams: RequestParam {
    fileprivate let children: [RequestParam]

    init(children: [RequestParam]) {
        self.children = children
    }

    func buildParam(_ request: inout URLRequest) {
        children.forEach {
            $0.buildParam(&request)
        }
    }
}

extension RequestParam {
    var unzip: [RequestParam] {
        if let combined = self as? CombinedParams {
            return combined.children
        }

        return [self]
    }
}
