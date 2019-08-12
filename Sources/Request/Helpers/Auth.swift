//
//  Authorization.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

/// The type of `Authentication` to use in the `Request`
///
/// Used with `Auth`
public enum AuthType: String {
    case basic = "Basic"
    case bearer = "Bearer"
    /*case digest = "Digest"
    case hoba = "HOBA"
    case mutual = "Mutual"
    case aws = "AWS4-HMAC-SHA256"*/
}

/// The `Authentication` type, and the key used
///
/// The `key` and `value` are merged in the `Authentication` header as `key value`.
/// For instance: `Basic username:password`, or `Bearer token`
///
/// You can use `.basic` and `.bearer` to simplify the process of authenticating your `Request`
public struct Auth {
    public let type: AuthType
    public let key: String
    public var value: String {
        get {
            return "\(type.rawValue) \(key)"
        }
    }
    
    public init(type: AuthType, key: String) {
        self.type = type
        self.key = key
    }
}

extension Auth {
    /// Authenticates using `username` and `password` directly
    public static func basic(username: String, password: String) -> Auth {
        return Auth(type: .basic, key: Data("\(username):\(password)".utf8).base64EncodedString())
    }
    
    /// Authenticates using a `token`
    public static func bearer(_ token: String) -> Auth {
        return Auth(type: .bearer, key: token)
    }
}
