//
//  Error.swift
//  Request
//
//  Created by Carson Katri on 7/11/19.
//

import Foundation

/// An error returned by the `Request`
public struct RequestError: Error {
    public let statusCode: Int
    public let error: Data?

    public var localizedDescription: String {
        guard let data = self.error else {
            return "Error code: \(self.statusCode)"
        }

        return String(data: data, encoding: .utf8) ?? "Error code: \(self.statusCode)"
    }
}
