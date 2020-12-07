//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

internal struct CombinedParams: RequestParam, SessionParam {
    fileprivate let children: [RequestParam]

    init(children: [RequestParam]) {
        self.children = children
    }

    func buildParam(_ request: inout URLRequest) {
        children
            .sorted { a, _ in (a is Url) }
            .filter { !($0 is SessionParam) || $0 is CombinedParams }
            .forEach {
                $0.buildParam(&request)
            }
    }

    func buildConfiguration(_ configuration: URLSessionConfiguration) {
        children
            .compactMap { $0 as? SessionParam }
            .forEach {
                $0.buildConfiguration(configuration)
            }
    }
}
