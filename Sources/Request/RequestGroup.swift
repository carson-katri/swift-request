//
//  RequestChain.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation

@_functionBuilder
struct RequestGroupBuilder {
    static func buildBlock(_ requests: Request...) -> [Request] {
        return requests
    }
}

class RequestGroup {
    let requests: [Request]
    
    private var onData: ((Int, Data?) -> Void)?
    private var onString: ((Int, String?) -> Void)?
    private var onJson: ((Int, Json?) -> Void)?
    private var onError: ((Int, RequestError) -> Void)?
    
    init(@RequestGroupBuilder requests: () -> [Request]) {
        self.requests = requests()
    }
    
    func onData(_ callback: @escaping ((Int, Data?) -> Void)) -> RequestGroup {
        self.onData = callback
        return self
    }
    
    func onString(_ callback: @escaping ((Int, String?) -> Void)) -> RequestGroup {
        self.onString = callback
        return self
    }
    
    func onJson(_ callback: @escaping ((Int, Json?) -> Void)) -> RequestGroup {
        self.onJson = callback
        return self
    }
    
    func onError(_ callback: @escaping ((Int, RequestError) -> Void)) -> RequestGroup {
        self.onError = callback
        return self
    }
    
    func call() {
        self.requests.enumerated().forEach { (index, _req) in
            var req = _req
            if self.onData != nil {
                req = req.onData { data in
                    self.onData!(index, data)
                }
            }
            if self.onString != nil {
                req = req.onString { string in
                    self.onString!(index, string)
                }
            }
            if self.onJson != nil {
                req = req.onJson { json in
                    self.onJson!(index, json)
                }
            }
            if self.onError != nil {
                req = req.onError { error in
                    self.onError!(index, error)
                }
            }
            req.call()
        }
    }
}
