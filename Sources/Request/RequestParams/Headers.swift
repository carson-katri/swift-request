//
//  Accept.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

public extension Header {
    static func Accept(_ type: MediaType) -> HeaderParam {
        return HeaderParam(key: "Accept", value: type.rawValue)
    }
    static func Accept(_ type: String) -> HeaderParam {
        return HeaderParam(key: "Accept", value: type)
    }
    static func Authorization(_ auth: Auth) -> HeaderParam {
        return HeaderParam(key: "Authorization", value: auth.value)
    }
    
    static func CacheControl(_ cache: CacheType) -> HeaderParam {
        return HeaderParam(key: "Cache-Control", value: cache.value)
    }
    static func ContentLength(_ octets: Int) -> HeaderParam {
        return HeaderParam(key: "Content-Length", value: "\(octets)")
    }
    static func ContentType(_ type: MediaType) -> HeaderParam {
        return HeaderParam(key: "Content-Type", value: type.rawValue)
    }
    
    static func Host(_ host: String) -> HeaderParam {
        return HeaderParam(key: "Host", value: host)
    }
    
    static func Origin(_ origin: String) -> HeaderParam {
        return HeaderParam(key: "Origin", value: origin)
    }
    
    static func Referer(_ url: String) -> HeaderParam {
        return HeaderParam(key: "Referer", value: url)
    }
    
    static func UserAgent(_ userAgent: UserAgent) -> HeaderParam {
        return HeaderParam(key: "User-Agent", value: userAgent.rawValue)
    }
}
