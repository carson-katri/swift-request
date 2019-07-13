//
//  Error.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

/// An error returned by the `Request`
public struct RequestError {
    public let statusCode: Int
    public let error: Data?
}
