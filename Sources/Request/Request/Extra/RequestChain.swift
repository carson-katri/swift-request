//
//  RequestChain.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

public extension Request {
    /// Creates a `Request` to be used in a `RequestChain`
    ///
    /// This `Request` takes `[Data?]` and `[RequestError?]` as parameters.
    /// These parameters contain the results of the previously called `Request`s
    ///
    ///     Request.chained { (data, err) in
    ///         Url("https://api.example.com/todos/\(Json.Parse(data[0]!)![0]["id"].int)")
    ///     }
    static func chained(@RequestBuilder builder: @escaping ([Data?], [RequestError?]) -> RequestParam) -> ([Data?], [RequestError?]) -> RequestParam {
        return builder
    }
}

@_functionBuilder
public struct RequestChainBuilder {
    public static func buildBlock(_ requests: (([Data?], [RequestError?]) -> RequestParam)...) -> [([Data?], [RequestError?]) -> RequestParam] {
        return requests
    }
}

/// Chains multiple `Request`s together.
///
/// The `Request`s in the chain are run in order.
/// To run multiple `Request`s in parallel, look at `RequestGroup`.
///
/// Instead of using `Request`, use `Request.chained` to build each `Request`.
/// This allows you to access the results and errors of every previous `Request`
///
///     RequestChain {
///         // Make our first request
///         Request.chained { (data, err) in
///             Url("https://api.example.com/todos")
///         }
///         // Now we can use the data from that request to make our 2nd
///         Request.chained { (data, err) in
///             Url("https://api.example.com/todos/\(Json.Parse(data[0]!)![0]["id"].int)")
///         }
///     }
///
/// - Precondition: You must have **at least 2** `Request`s in your chain, or the compiler will have a fit.
public struct RequestChain {
    private let requests: [([Data?], [RequestError?]) -> RequestParam]
    
    public init(@RequestChainBuilder requests: () -> [([Data?], [RequestError?]) -> RequestParam]) {
        self.requests = requests()
    }
    
    /// Perform the `Request`s in the chain, and optionally respond with the data from each one when complete.
    public func call(_ callback: @escaping ([Data?], [RequestError?]) -> Void = { (_, _) in }) {
        func _call(_ index: Int, data: [Data?], errors: [RequestError?], callback: @escaping ([Data?], [RequestError?]) -> Void) {
            var params = self.requests[index](data, errors)
            if !(params is CombinedParams) {
                params = CombinedParams(children: [params])
            } else {
                params = self.requests[index](data, errors) as! CombinedParams
            }
            Request(params: params as! CombinedParams)
            .onData { res in
                if index + 1 >= self.requests.count {
                    callback(data + [res], errors + [nil])
                } else {
                    _call(index + 1, data: data + [res], errors: errors + [nil], callback: callback)
                }
            }
            .onError { err in
                if index + 1 >= self.requests.count {
                    callback(data + [nil], errors + [err])
                } else {
                    _call(index + 1, data: data + [nil], errors: errors + [err], callback: callback)
                }
            }
            .call()
        }
        _call(0, data: [], errors: [], callback: callback)
    }
}
