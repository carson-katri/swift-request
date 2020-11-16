//
//  File.swift
//  
//
//  Created by brennobemoura on 15/11/20.
//

import Foundation

/// Sets the query string of the `Request`
///
/// `[key:value, key2:value2]` becomes `?key=value&key2=value2`
public struct Query: RequestParam {
    private let children: [QueryParam]

    /// Creates the `Query` from `[key:value]` pairs
    /// - Parameter params: Key-value pairs describing the `Query`
    public init(_ params: [String: Any?]) {
        children = params.map {
            QueryParam($0.key, value: $0.value)
        }
    }

    /// Creates the `Query` directly from an array of `QueryParam`s
    public init(@RequestBuilder _ params: () -> RequestParam) {
        self.children = params().unzip.compactMap {
            guard let queryParam = $0 as? QueryParam else {
                fatalError("Query should only contains QueryParam")
            }

            return queryParam
        }
    }

    public func buildParam(_ request: inout URLRequest) {
        guard
            let url = request.url,
            var components = URLComponents(string: url.absoluteString)
        else {
            fatalError("Couldn't create URLComponents, check if parameters are valid")
        }

        components.queryItems = children.map { $0.urlQueryItem }
        request.url = components.url
    }
}
