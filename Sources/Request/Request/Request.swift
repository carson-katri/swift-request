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

// TODO: Fix EXC_BAD_ACCESS instead of workaround with `struct`
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
public struct AnyRequest<ResponseType>/*: ObservableObject, Identifiable*/ where ResponseType: Decodable {
    public let combineIdentifier = CombineIdentifier()

    private var params: CombinedParams
    
    private var onData: ((Data) -> Void)?
    private var onString: ((String) -> Void)?
    private var onJson: ((Json) -> Void)?
    private var onObject: ((ResponseType) -> Void)?
    private var onError: ((RequestError) -> Void)?
    private var updatePublisher: AnyPublisher<Void,Never>?
    
    /*@Published*/ public var response: Response = Response()
    
    public init(@RequestBuilder builder: () -> RequestParam) {
        let params = builder()
        if !(params is CombinedParams) {
            self.params = CombinedParams(children: [params])
        } else {
            self.params = params as! CombinedParams
        }
        self.response = Response()
    }
    
    internal init(params: CombinedParams) {
        self.params = params
        self.response = Response()
    }
    
    internal init(params: CombinedParams,
                  onData: ((Data) -> Void)?,
                  onString: ((String) -> Void)?,
                  onJson: ((Json) -> Void)?,
                  onObject: ((ResponseType) -> Void)?,
                  onError: ((RequestError) -> Void)?,
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
    
    /// Handle any `RequestError`s thrown by the `Request`
    public func onError(_ callback: @escaping (RequestError) -> Void) -> Self {
        Self.init(params: params, onData: onData, onString: onString, onJson: onJson, onObject: onObject, onError: callback, updatePublisher: updatePublisher)
    }
    
    /// Performs the `Request`, and calls the `onData`, `onString`, `onJson`, and `onError` callbacks when appropriate.
    public func call() {
        performRequest()
        if let updatePublisher = self.updatePublisher {
            updatePublisher.subscribe(self)
        }
    }

    private func performRequest() {
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
        URLSession(configuration: configuration).dataTask(with: request) { data, res, err in
            if let res = res as? HTTPURLResponse {
                let statusCode = res.statusCode
                if statusCode < 200 || statusCode >= 300 {
                    if let onError = self.onError {
                        onError(RequestError(statusCode: statusCode, error: data))
                        return
                    }
                }
            } else if let err = err, let onError = self.onError {
                onError(RequestError(statusCode: -1, error: err.localizedDescription.data(using: .utf8)))
            }
            if let data = data {
                if let onData = self.onData {
                    onData(data)
                }
                if let onString = self.onString {
                    if let string = String(data: data, encoding: .utf8) {
                        onString(string)
                    }
                }
                if let onJson = self.onJson {
                    if let string = String(data: data, encoding: .utf8) {
                        if let json = try? Json(string) {
                            onJson(json)
                        }
                    }
                }
                if let onObject = self.onObject {
                    if let decoded = try? JSONDecoder().decode(ResponseType.self, from: data) {
                        onObject(decoded)
                    }
                }
                self.response.data = data
            }
        }.resume()
    }

    /// Sets the `Request` to be performed additional times after the initial `call`
    public func update<T: Publisher>(publisher: T) -> Self {
        var newPublisher = publisher
            .map {_ in Void()}
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

extension AnyRequest : Subscriber {
    public typealias Input = Void
    public typealias Failure = Never

    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: Void) -> Subscribers.Demand {
        self.performRequest()
        return .none
    }

    public func receive(completion: Subscribers.Completion<Never>) {
        return
    }
}
