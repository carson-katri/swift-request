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

/// An `ObservableObject` that allows you to use a `Request` with `SwiftUI` more easily.
public final class Response: ObservableObject, Identifiable {
    public let willChange = PassthroughSubject<Response, Never>()
    
    @Published public var json: Json? = nil
    @Published public var string: Json? = nil
    @Published public var data: Data? = nil
}
