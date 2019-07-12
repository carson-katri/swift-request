//
//  Authorization.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

public enum AuthType: String {
    case basic = "Basic"
    case bearer = "Bearer"
    /*case digest = "Digest"
    case hoba = "HOBA"
    case mutual = "Mutual"
    case aws = "AWS4-HMAC-SHA256"*/
}

public struct Auth {
    let type: AuthType
    let key: String
    var value: String {
        get {
            return "\(type.rawValue) \(key)"
        }
    }
    
    init(type: AuthType, key: String) {
        self.type = type
        self.key = key
    }
}

extension Auth {
    static func basic(username: String, password: String) -> Auth {
        return Auth(type: .basic, key: "\(username):\(password)")
    }
    
    static func bearer(_ token: String) -> Auth {
        return Auth(type: .bearer, key: token)
    }
}
