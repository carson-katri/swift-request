//
//  CacheType.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

/// The caching method, to be used with the `Cache-Control` header
public struct CacheType {
    public let value: String
    
    public static let noCache = CacheType(value: "no-cache")
    public static let noStore = CacheType(value: "no-store")
    public static let noTransform = CacheType(value: "no-transform")
    public static let onlyIfCached = CacheType(value: "only-if-cached")
    public static func maxAge(_ seconds: Int) -> CacheType {
        return CacheType(value: "max-age=\(seconds)")
    }
    public static let maxStale = CacheType(value: "max-stale")
    public static func maxStale(_ seconds: Int) -> CacheType {
        return CacheType(value: "max-stale=\(seconds)")
    }
    public static func minFresh(_ seconds: Int) -> CacheType {
        return CacheType(value: "min-fresh=\(seconds)")
    }
}
