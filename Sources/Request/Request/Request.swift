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
public class AnyRequest<ResponseType>: ObservableObject, Identifiable where ResponseType: Decodable {
    public var willChange = PassthroughSubject<AnyRequest, Never>()
    
    private var params: CombinedParams
    
    private var onData: ((Data) -> Void)?
    private var onString: ((String) -> Void)?
    private var onJson: ((Json) -> Void)?
    private var onObject: ((ResponseType) -> Void)?
    private var onError: ((RequestError) -> Void)?
    
    @Published public var response: Response = Response()
    
    public init(@RequestBuilder builder: () -> RequestParam) {
        let params = builder()
        if !(params is CombinedParams) {
            self.params = CombinedParams(children: [params])
        } else {
            self.params = builder() as! CombinedParams
        }
        self.response = Response()
    }
    
    internal init(params: CombinedParams) {
        self.params = params
        self.response = Response()
    }
    
    /// Sets the `onData` callback to be run whenever `Data` is retrieved
    public func onData(_ callback: @escaping (Data) -> Void) -> Self {
        self.onData = callback
        return self
    }
    
    /// Sets the `onString` callback to be run whenever a `String` is retrieved
    public func onString(_ callback: @escaping (String) -> Void) -> Self {
        self.onString = callback
        return self
    }
    
    /// Sets the `onData` callback to be run whenever `Json` is retrieved
    public func onJson(_ callback: @escaping (Json) -> Void) -> Self {
        self.onJson = callback
        return self
    }
    
    /// Sets the `onObject` callback to be run whenever `Data` is retrieved
    public func onObject(_ callback: @escaping (ResponseType) -> Void) -> Self {
        self.onObject = callback
        return self
    }
    
    /// Handle any `RequestError`s thrown by the `Request`
    public func onError(_ callback: @escaping (RequestError) -> Void) -> Self {
        self.onError = callback
        return self
    }
    
    /// Performs the `Request`, and calls the `onData`, `onString`, `onJson`, and `onError` callbacks when appropriate.
    public func call() {
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
        
        // PERFORM REQUEST
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let httpURLRes = res as? HTTPURLResponse {
                let statusCode = httpURLRes.statusCode
                if statusCode < 200 || statusCode >= 300 {
                    if let onError = self.onError {
                        onError(RequestError(statusCode: statusCode, error: data))
                        return
                    }
                }
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
}
