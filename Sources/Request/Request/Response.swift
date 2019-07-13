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
final class Response: BindableObject {
    let didChange = PassthroughSubject<Response, Never>()
    
    var json: Json? = nil {
        didSet {
            didChange.send(self)
        }
    }
    var string: Json? = nil {
        didSet {
            didChange.send(self)
        }
    }
    var data: Data? = nil {
        didSet {
            didChange.send(self)
        }
    }
}
