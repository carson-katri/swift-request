//
//  RequestView.swift
//  PackageTests
//
//  Created by Carson Katri on 7/9/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI
import Json


/// A view that asynchronously loads data from the web
///
/// `RequestView` is powered by a `Request`. It handles loading the data, and you can focus on building your app.
///
/// It takes a `Request`, a placeholder and any content you want rendered.
public struct RequestView<Content, Placeholder> : View where Content: View, Placeholder: View {
    private let request: Request
    private let content: (Data?) -> TupleView<(Content, Placeholder)>
    
    @State private var oldReq: Request? = nil
    @State private var data: Data? = nil
    
    public init(_ request: Request, @ViewBuilder data: @escaping (Data?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = data
    }
    
    public init(_ request: Request, @ViewBuilder string: @escaping (String?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = { data in
            guard let data = data else {
                return string(nil)
            }
            return string(String(data: data, encoding: .utf8))
        }
    }
    
    public init(_ request: Request, @ViewBuilder json: @escaping (Json?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = { data in
            guard let data = data else {
                return json(nil)
            }
            return json(try? Json(data))
        }
    }
    
    public init<ResponseType: Decodable>(_ type: ResponseType.Type, _ request: Request, @ViewBuilder content: @escaping (ResponseType?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = { data in
            guard let data = data else {
                return content(nil)
            }
            return content(try? JSONDecoder().decode(type, from: data))
        }
    }
    
    public var body: some View {
        if data == nil || oldReq == nil || oldReq?.id != request.id {
            let req = self.request.onData { data in
                self.oldReq = self.request
                self.data = data
            }
            req.call()
            return AnyView(content(nil).value.1)
        } else {
            return AnyView(content(data).value.0)
        }
    }
}
