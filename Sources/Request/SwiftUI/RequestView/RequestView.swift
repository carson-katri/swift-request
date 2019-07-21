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
public typealias RequestView<Content: View, Placeholder: View> = AnyRequestView<Data, Content, Placeholder>

/// `RequestView`, but with Codable support.
public struct AnyRequestView<ResponseType, Content, Placeholder> : View where ResponseType: Decodable, Content: View, Placeholder: View {
    private let request: AnyRequest<ResponseType>
    private let content: (ResponseType?) -> TupleView<(Content, Placeholder)>
    
    @State private var object: ResponseType? = nil
    @State private var data: Data? = nil
    
    public init(_ request: AnyRequest<ResponseType>, @ViewBuilder content: @escaping (ResponseType?) -> TupleView<(Content, Placeholder)>) {
        self.request = request
        self.content = content
    }
    
    public var body: some View {
        if object != nil {
            return AnyView(content(object).value.0)
        } else if data != nil {
            return AnyView(content((data as! ResponseType)).value.0)
        } else {
            var req = self.request.onObject { object in
                self.object = object
            }
            if ResponseType.self == Data.self {
                req = self.request.onData { data in
                    self.data = data
                }
            }
            req.call()
            return AnyView(content(nil).value.1)
        }
    }
}
