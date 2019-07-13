//
//  Accept.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

public extension Header {
    /// Specifies the media type the client is expecting and able to handle
    static func Accept(_ type: MediaType) -> HeaderParam {
        return HeaderParam(key: "Accept", value: type.rawValue)
    }
    /// Sets the `Accept` header to a custom MIME type
    /// - Parameter type: The MIME type, such as: `application/json`
    static func Accept(_ type: String) -> HeaderParam {
        return HeaderParam(key: "Accept", value: type)
    }
    /// Authenticates the `Request` for HTTP authentication
    static func Authorization(_ auth: Auth) -> HeaderParam {
        return HeaderParam(key: "Authorization", value: auth.value)
    }
    
    /// Specifies caching mechanisms for the `Request`
    static func CacheControl(_ cache: CacheType) -> HeaderParam {
        return HeaderParam(key: "Cache-Control", value: cache.value)
    }
    /// The length of the `Body` in octets (8-bit bytes)
    /// - Parameter octets: Length in 8-bit bytes
    static func ContentLength(_ octets: Int) -> HeaderParam {
        return HeaderParam(key: "Content-Length", value: "\(octets)")
    }
    /// The `MediaType` of the `Body`
    /// - Note: Used with `Method(.post)` and `Method(.put)`
    static func ContentType(_ type: MediaType) -> HeaderParam {
        return HeaderParam(key: "Content-Type", value: type.rawValue)
    }
    
    /// The domain name of the server (for virtual hosting), and optionally, the port.
    static func Host(_ host: String, port: String = "") -> HeaderParam {
        return HeaderParam(key: "Host", value: host + port)
    }
    
    /// Sets the `Request` up for CORS
    /// - Parameter origin: The url of the origin of the `Request`
    static func Origin(_ origin: String) -> HeaderParam {
        return HeaderParam(key: "Origin", value: origin)
    }
    
    /// The address of the previous page which requested the current one
    /// - Parameter url: The URL of the previous page
    static func Referer(_ url: String) -> HeaderParam {
        return HeaderParam(key: "Referer", value: url)
    }
    
    /// Sets the user agent string
    /// - Parameter userAgent: The `UserAgent` (a `String`)
    static func UserAgent(_ userAgent: UserAgent) -> HeaderParam {
        return HeaderParam(key: "User-Agent", value: userAgent.rawValue)
    }
}
