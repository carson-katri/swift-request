//
//  Response.swift
//  PackageTests
//
//  Created by Carson Katri on 7/1/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation
import Json
import SwiftUI
import Combine

/// A `BindableObject` that allows you to use a `Request` with `SwiftUI` more easily.
public final class Response: BindableObject {
    public let willChange = PassthroughSubject<Response, Never>()
    
    public var json: Json? = nil {
        willSet {
            willChange.send(self)
        }
    }
    public var string: Json? = nil {
        willSet {
            willChange.send(self)
        }
    }
    public var data: Data? = nil {
        willSet {
            willChange.send(self)
        }
    }
}
