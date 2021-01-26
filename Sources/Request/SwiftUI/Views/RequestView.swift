//
//  RequestView.swift
//  PackageTests
//
//  Created by Carson Katri on 7/9/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI
import Combine

/// A view that asynchronously loads data from the web
///
/// `RequestView` is powered by a `Request`. It handles loading the data, and you can focus on building your app.
///
/// It takes a `Request`, a placeholder and any content you want rendered.
public struct RequestView<Value, Content> : View where Value: Decodable, Content: View {
    private let request: AnyRequest<Value>
    private let content: (RequestStatus<Value>) -> Content
    @State private var result: RequestStatus<Value> = .loading
    @State private var performedOnAppear = false
    @State private var cancellables: [AnyCancellable] = []
    
    public init(
        _ request: AnyRequest<Value>,
        @ViewBuilder content: @escaping (RequestStatus<Value>) -> Content
    ) {
        print(request)
        self.request = request
        self.content = content
    }
    
    func perform() {
        self.result = .loading
        request
            .objectPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                case let .failure(error):
                    self.result = .failure(error)
                case .finished: break
                }
            } receiveValue: {
                self.result = .success($0)
            }
            .store(in: &cancellables)
    }
    
    public var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            Group {
                content(result)
            }
                .onAppear {
                    if !performedOnAppear {
                        perform()
                        performedOnAppear = true
                    }
                }
                .onChange(of: request) { _ in
                    perform()
                }
        } else {
            Group {
                content(result)
            }
                .onAppear {
                    if !performedOnAppear {
                        perform()
                        performedOnAppear = true
                    }
                }
        }
    }
}

extension RequestView where Value == Data, Content == AnyView {
    @available(*, deprecated, message: "Optional result bodies are deprecated. Please use `RequestStatus` bodies instead.")
    public init<Content: View, Placeholder: View>(
        _ request: Request,
        @ViewBuilder content: @escaping (Data?) -> TupleView<(Content, Placeholder)>
    ) {
        self.request = request
        self.content = {
            switch $0 {
            case .loading, .failure: return AnyView(content(nil).value.1)
            case let .success(result): return AnyView(content(result).value.0)
            }
        }
    }
    
    @available(*, deprecated, message: "Optional result bodies are deprecated. Please use `RequestStatus` bodies instead.")
    public init<ResponseType: Decodable, Content: View, Placeholder: View>(
        _ type: ResponseType.Type,
        _ request: Request,
        @ViewBuilder content: @escaping (ResponseType?) -> TupleView<(Content, Placeholder)>
    ) {
        self.request = request
        self.content = {
            switch $0 {
            case .loading, .failure: return AnyView(content(nil).value.1)
            case let .success(data):
                if let res = try? JSONDecoder().decode(type, from: data) {
                    return AnyView(content(res).value.0)
                } else {
                    return AnyView(content(nil).value.1)
                }
            }
        }
    }
}
