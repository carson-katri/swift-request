//
//  RequestChain.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

extension Request {
    static func chained(@RequestBuilder builder: @escaping ([Data?], [RequestError?]) -> RequestParam) -> ([Data?], [RequestError?]) -> RequestParam {
        return builder
    }
}

@_functionBuilder
struct RequestChainBuilder {
    static func buildBlock(_ requests: (([Data?], [RequestError?]) -> RequestParam)...) -> [([Data?], [RequestError?]) -> RequestParam] {
        return requests
    }
}

struct RequestChain {
    let requests: [([Data?], [RequestError?]) -> RequestParam]
    
    init(@RequestChainBuilder requests: () -> [([Data?], [RequestError?]) -> RequestParam]) {
        self.requests = requests()
    }
    
    func call(_ callback: @escaping ([Data?], [RequestError?]) -> Void = { (_, _) in }) {
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
