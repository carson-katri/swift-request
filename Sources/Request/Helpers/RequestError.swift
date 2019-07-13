//
//  Error.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

/// An error returned by the `Request`
public struct RequestError {
    let statusCode: Int
    let error: Data?
}
