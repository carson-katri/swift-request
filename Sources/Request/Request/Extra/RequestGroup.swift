//
//  RequestChain.swift
//  Request
//
//  Created by Carson Katri on 7/10/19.
//

import Foundation
import Json

@resultBuilder
public struct RequestGroupBuilder {
    public static func buildBlock(_ requests: Request...) -> [Request] {
        return requests
    }
}

/// Performs multiple `Request`s simultaneously, and responds with the result of them all.
///
/// All of the `Request`s are run at the same time, and therefore know nothing of the previous `Request`'s response.
/// To chain requests together to be run in order, see `RequestChain`.
///
/// **Example:**
///
///     RequestGroup {
///         Request {
///             Url("https://api.example.com/todos")
///         }
///         Request {
///             Url("https://api.example.com/todos/1/save")
///             Method(.post)
///             Body(["name":"Hello World"])
///         }
///     }
///
/// You can use `onData`, `onString`, `onJson`, and `onError` like you would with a normal `Request`.
/// However, it will also return the index of the `Request`, along with the data.
public struct RequestGroup {
    internal let requests: [Request]
    
    private let onData: ((Int, Data?) -> Void)?
    private let onString: ((Int, String?) -> Void)?
    private let onJson: ((Int, Json?) -> Void)?
    private let onError: ((Int, Error) -> Void)?
    
    public init(@RequestGroupBuilder requests: () -> [Request]) {
        self.requests = requests()
        self.onData = nil
        self.onString = nil
        self.onJson = nil
        self.onError = nil
    }
    
    internal init(requests: [Request],
                  onData: ((Int, Data?) -> Void)?,
                  onString: ((Int, String?) -> Void)?,
                  onJson: ((Int, Json?) -> Void)?,
                  onError: ((Int, Error) -> Void)?) {
        self.requests = requests
        self.onData = onData
        self.onString = onString
        self.onJson = onJson
        self.onError = onError
    }
    
    public func onData(_ callback: @escaping ((Int, Data?) -> Void)) -> RequestGroup {
        Self.init(requests: requests, onData: callback, onString: onString, onJson: onJson, onError: onError)
    }
    
    public func onString(_ callback: @escaping ((Int, String?) -> Void)) -> RequestGroup {
        Self.init(requests: requests, onData: onData, onString: callback, onJson: onJson, onError: onError)
    }
    
    public func onJson(_ callback: @escaping ((Int, Json?) -> Void)) -> RequestGroup {
        Self.init(requests: requests, onData: onData, onString: onString, onJson: callback, onError: onError)
    }
    
    public func onError(_ callback: @escaping ((Int, Error) -> Void)) -> RequestGroup {
        Self.init(requests: requests, onData: onData, onString: onString, onJson: onJson, onError: callback)
    }
    
    /// Perform the `Request`s in the group.
    public func call() {
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
