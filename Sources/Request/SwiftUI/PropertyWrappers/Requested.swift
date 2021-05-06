//
//  Requested.swift
//  
//
//  Created by Carson Katri on 1/17/21.
//

import SwiftUI
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper
public struct Requested<Value: Decodable>: DynamicProperty {
    @StateObject private var requestStore: RequestStore
    
    final class RequestStore: ObservableObject {
        @Published var status: RequestStatus<Value> = .loading
        private var cancellable: AnyCancellable?
        var request: AnyRequest<Value> {
            didSet {
                call()
            }
        }
        
        init(request: AnyRequest<Value>) {
            self.request = request
            call()
        }
        
        func call() {
            print("Calling")
            self.status = .loading
            cancellable = request
                .objectPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        self?.status = .failure(error)
                    case .finished: break
                    }
                } receiveValue: { [weak self] result in
                    self?.status = .success(result)
                }
        }
    }
    
    public init(wrappedValue: AnyRequest<Value>) {
        self._requestStore = .init(wrappedValue: .init(request: wrappedValue))
    }
    
    public var wrappedValue: AnyRequest<Value> {
        get {
            requestStore.request
        }
        nonmutating set {
            requestStore.request = newValue
        }
    }
    
    public var projectedValue: RequestStatus<Value> {
        requestStore.status
    }
}
