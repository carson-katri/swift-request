//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation
import Json
import SwiftUI
import Combine

/// The building block for making an HTTP request
///
/// Built using a `@_functionBuilder`, available in Swift 5.1
///
/// *Example*:
///
///     Request {
///         Url("https://api.example.com/todos")
///     }
///
/// To make the `Request`, use the method `call`
///
/// To accept data from the `Request`, use `onData`, `onString`, and `onJson`.
///
/// **See Also:**
/// `Url`, `Method`, `Header`, `Query`, `Body`
///
/// - Precondition: The `Request` body must contain **exactly one** `Url`
public typealias Request = AnyRequest<Data>

/// Tha base class of `Request` to be used with a `Codable` `ResponseType` when using the `onObject` callback
///
/// *Example*:
///
///     AnyRequest<[MyCodableStruct]> {
///         Url("https://api.example.com/myData")
///     }
///     .onObject { myCodableStructs in
///         ...
///     }
public struct AnyRequest<ResponseType>: Publisher where ResponseType: Decodable {
    public let combineIdentifier = CombineIdentifier()

    private var params: CombinedParams
    
    internal var onData: ((Data) -> Void)?
    internal var onString: ((String) -> Void)?
    internal var onJson: ((Json) -> Void)?
    internal var onObject: ((ResponseType) -> Void)?
    internal var onError: ((Error) -> Void)?
    internal var updatePublisher: AnyPublisher<Void,Never>?

    public typealias Output = URLSession.DataTaskPublisher.Output
    public typealias Failure = Error
    
    public init(@RequestBuilder builder: () -> RequestParam) {
        let params = builder()
        if !(params is CombinedParams) {
            self.params = CombinedParams(children: [params])
        } else {
            self.params = params as! CombinedParams
        }
    }
    
    internal init(params: CombinedParams) {
        self.params = params
    }
    
    internal init(params: CombinedParams,
                  onData: ((Data) -> Void)?,
                  onString: ((String) -> Void)?,
                  onJson: ((Json) -> Void)?,
                  onObject: ((ResponseType) -> Void)?,
                  onError: ((Error) -> Void)?,
                  updatePublisher: AnyPublisher<Void,Never>?) {
        self.params = params
        self.onData = onData
        self.onString = onString
        self.onJson = onJson
        self.onObject = onObject
        self.onError = onError
        self.updatePublisher = updatePublisher
    }
    
    /// Sets the `onData` callback to be run whenever `Data` is retrieved
    public func onData(_ callback: @escaping (Data) -> Void) -> Self {
        Self.init(params: params, onData: callback, onString: onString, onJson: onJson, onObject: onObject, onError: onError, updatePublisher: updatePublisher)
    }

    /// Sets the `onString` callback to be run whenever a `String` is retrieved
    public func onString(_ callback: @escaping (String) -> Void) -> Self {
        Self.init(params: params, onData: onData, onString: callback, onJson: onJson, onObject: onObject, onError: onError, updatePublisher: updatePublisher)
    }

    /// Sets the `onData` callback to be run whenever `Json` is retrieved
    public func onJson(_ callback: @escaping (Json) -> Void) -> Self {
        Self.init(params: params, onData: onData, onString: onString, onJson: callback, onObject: onObject, onError: onError, updatePublisher: updatePublisher)
    }

    /// Sets the `onObject` callback to be run whenever `Data` is retrieved
    public func onObject(_ callback: @escaping (ResponseType) -> Void) -> Self {
        Self.init(params: params, onData: onData, onString: onString, onJson: onJson, onObject: callback, onError: onError, updatePublisher: updatePublisher)
    }

    /// Handle any `Error`s thrown by the `Request`
    public func onError(_ callback: @escaping (Error) -> Void) -> Self {
        Self.init(params: params, onData: onData, onString: onString, onJson: onJson, onObject: onObject, onError: callback, updatePublisher: updatePublisher)
    }
    
    /// Performs the `Request`, and calls the `onData`, `onString`, `onJson`, and `onError` callbacks when appropriate.
    public func call() {
        buildSession()
            .subscribe(self)
        if let updatePublisher = self.updatePublisher {
            updatePublisher
                .subscribe(UpdateSubscriber(request: self))
        }
    }

    internal func buildSession() -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        // Url
        guard var components = URLComponents(string: params.children!.filter({ $0.type == .url })[0].value as! String) else {
            fatalError("Missing Url in Request body")
        }
        
        // Query, QueryParam
        let query = params.children!.filter({ $0.type == .query }).reduce([QueryParam]()) { (prev, param) in
            if param.children != nil {
                return prev + (param.children as! [QueryParam])
            } else {
                return prev + ([param] as! [QueryParam])
            }
        }
        components.queryItems = query.map { param in
            return URLQueryItem(name: param.key!, value: (param.value as! String))
        }
        
        // BUILD REQUEST
        var request = URLRequest(url: components.url!)
        let method = params.children!.filter({ $0.type == .method })
        if method.count > 0 {
            request.httpMethod = (method[0].value as! MethodType).rawValue
        }
        
        // Headers, Header
        let headers = params.children!.filter({ $0.type == .header }).reduce([HeaderParam]()) { (prev, param) in
            if param.children != nil {
                return prev + (param.children as! [HeaderParam])
            } else if param is HeaderParam {
                return prev + ([param] as! [HeaderParam])
            }
            return prev
        }
        headers.forEach { header in
            request.addValue(header.value as! String, forHTTPHeaderField: header.key!)
        }
        
        // Body
        let body = params.children!.filter({ $0.type == .body })
        if body.count > 0 {
            request.httpBody = body[0].value as? Data
        }
        
        // Configuration
        let configuration = URLSessionConfiguration.default
        let timeouts = params.children!.filter { $0.type == .timeout }
        if timeouts.count > 0 {
            for timeout in timeouts {
                guard let (source, interval) = timeout.value as? (Timeout.Source, TimeInterval) else {
                    fatalError("Invalid Timeout \(timeout)")
                }
                if source.contains(.request) {
                    configuration.timeoutIntervalForRequest = interval
                }
                if source.contains(.resource) {
                    configuration.timeoutIntervalForResource = interval
                }
            }
        }
        
        
        // PERFORM REQUEST
        return URLSession(configuration: configuration).dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }

    /// Sets the `Request` to be performed additional times after the initial `call`
    public func update<T: Publisher>(publisher: T) -> Self {
        var newPublisher = publisher
            .map { _ in }
            .assertNoFailure()
            .eraseToAnyPublisher()
        if let updatePublisher = self.updatePublisher {
            newPublisher = newPublisher.merge(with: updatePublisher).eraseToAnyPublisher()
        }
        return Self.init(params: params, onData: onData, onString: onString, onJson: onJson, onObject: onObject, onError: onError, updatePublisher: newPublisher)
    }

    /// Sets the `Request` to be repeated periodically after the initial `call`
    public func update(every seconds: TimeInterval) -> Self {
        self.update(publisher: Timer.publish(every: seconds, on: .main, in: .common).autoconnect())
    }
}
