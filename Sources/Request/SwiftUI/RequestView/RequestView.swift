//
//  RequestView.swift
//  PackageTests
//
//  Created by Carson Katri on 7/9/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI

/// A view that asynchronously loads data from the web
///
/// `RequestView` is powered by a `Request`. It handles loading the data, and you can focus on building your app.
///
/// It takes a `Request`, a placeholder and any content you want rendered.
public struct RequestView<Content, Placeholder> : View where Content: View, Placeholder: View {
    private let request: Request
    private let content: (Data?) -> TupleView<(Content, Placeholder)>
    
    @State private var data: Data? = nil
    
    public init(_ request: Request, @ViewBuilder content: @escaping (Data?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = content
    }
    
    public init<ResponseType: Decodable>(_ type: ResponseType.Type, _ request: Request, @ViewBuilder content: @escaping (ResponseType?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = { data in
            var object: ResponseType? = nil
            if data != nil {
                object = try? JSONDecoder().decode(type, from: data!)
            }
            return content(object)
        }
    }
    
    public var body: some View {
        if data != nil {
            return AnyView(content(data).value.0)
        } else {
            let req = self.request.onData { data in
                self.data = data
            }
            req.call()
            return AnyView(content(nil).value.1)
        }
    }
}
