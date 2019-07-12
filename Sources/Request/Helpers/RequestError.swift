//
//  Error.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

public struct RequestError {
    let statusCode: Int
    let error: Data?
}
