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
public struct AnyRequest<ResponseType> where ResponseType: Decodable {
    public let combineIdentifier = CombineIdentifier()

    private var params: [RequestParam]
    
    internal var onData: ((Data) -> Void)?
    internal var onString: ((String) -> Void)?
    internal var onJson: ((Json) -> Void)?
    internal var onObject: ((ResponseType) -> Void)?
    internal var onError: ((Error) -> Void)?
    internal var updatePublisher: AnyPublisher<Void,Never>?
    
    public init(@RequestBuilder builder: () -> RequestParam) {
        self.params = builder().unzip
    }
    
    internal init(params: [RequestParam]) {
        self.params = params
    }
    
    internal func modify(_ modify: (inout Self) -> Void) -> Self {
        var mutableSelf = self
        modify(&mutableSelf)
        return mutableSelf
    }
    
    /// Sets the `onData` callback to be run whenever `Data` is retrieved
    public func onData(_ callback: @escaping (Data) -> Void) -> Self {
        modify { $0.onData = callback }
    }

    /// Sets the `onString` callback to be run whenever a `String` is retrieved
    public func onString(_ callback: @escaping (String) -> Void) -> Self {
        modify { $0.onString = callback }
    }

    /// Sets the `onData` callback to be run whenever `Json` is retrieved
    public func onJson(_ callback: @escaping (Json) -> Void) -> Self {
        modify { $0.onJson = callback }
    }

    /// Sets the `onObject` callback to be run whenever `Data` is retrieved
    public func onObject(_ callback: @escaping (ResponseType) -> Void) -> Self {
        modify { $0.onObject = callback }
    }

    /// Handle any `Error`s thrown by the `Request`
    public func onError(_ callback: @escaping (Error) -> Void) -> Self {
        modify { $0.onError = callback }
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
        let params = self.params.sorted(by: { $0 is Url || ($1 is SessionConfiguration) })

        guard params.first is Url else {
            fatalError("Request should contain at least one Url")
        }

        var request = URLRequest(url: URL(string: "https://")!)
        for param in params where !(param is SessionConfiguration) {
            param.buildParam(&request)
        }
        
        // Configuration
        let configuration = URLSessionConfiguration.default
        for config in params where config is SessionConfiguration {
            (config as? SessionConfiguration)?.buildConfiguration(configuration)
        }

        // PERFORM REQUEST
        return URLSession(configuration: configuration).dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }

    /// Sets the `Request` to be performed additional times after the initial `call`
    public func update<T: Publisher>(publisher: T) -> Self {
        modify {
            $0.updatePublisher = publisher
                .map {_ in  }
                .assertNoFailure()
                .merge(with: self.updatePublisher ?? Empty().eraseToAnyPublisher())
                .eraseToAnyPublisher()
        }
    }

    /// Sets the `Request` to be repeated periodically after the initial `call`
    public func update(every seconds: TimeInterval) -> Self {
        self.update(publisher: Timer.publish(every: seconds, on: .main, in: .common).autoconnect())
    }
}
