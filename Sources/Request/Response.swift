//
//  Response.swift
//  PackageTests
//
//  Created by Carson Katri on 7/1/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// A `BindableObject` that allows you to use a `Request` with `SwiftUI` more easily.
public final class Response: BindableObject {
    public let didChange = PassthroughSubject<Response, Never>()
    
    public var json: Json? = nil {
        didSet {
            didChange.send(self)
        }
    }
    public var string: Json? = nil {
        didSet {
            didChange.send(self)
        }
    }
    public var data: Data? = nil {
        didSet {
            didChange.send(self)
        }
    }
}
