//
//  RequestGroup+Combine.swift
//  
//
//  Created by Carson Katri on 7/27/20.
//

import Combine
import Foundation

extension RequestGroup: Publisher {
    public typealias Output = [URLSession.DataTaskPublisher.Output]
    public typealias Failure = Error
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        Publishers.Sequence(sequence: requests)
            .flatMap { $0 }
            .collect()
            .subscribe(subscriber)
    }
}
