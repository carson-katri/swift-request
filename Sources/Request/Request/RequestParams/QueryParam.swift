//
//  Query.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

/// A key-value pair for a part of the query string
public struct QueryParam: RequestParam {
    private var key: String
    private var value: String
    
    public init(_ key: String, value: String) {
        self.key = key
        self.value = value
    }

    public func buildParam(_ request: inout URLRequest) {
        guard
            let url = request.url,
            var components = URLComponents(string: url.absoluteString)
        else {
            fatalError("Couldn't create URLComponents, check if parameters are valid")
        }

        components.queryItems = [urlQueryItem]
        request.url = components.url
    }
}

extension QueryParam {
    var urlQueryItem: URLQueryItem {
        URLQueryItem(name: key, value: value)
    }
}
