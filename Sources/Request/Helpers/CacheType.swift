//
//  CacheType.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

public struct CacheType {
    let value: String
    
    static let noCache = CacheType(value: "no-cache")
    static let noStore = CacheType(value: "no-store")
    static let noTransform = CacheType(value: "no-transform")
    static let onlyIfCached = CacheType(value: "only-if-cached")
    static func maxAge(_ seconds: Int) -> CacheType {
        return CacheType(value: "max-age=\(seconds)")
    }
    static let maxStale = CacheType(value: "max-stale")
    static func maxStale(_ seconds: Int) -> CacheType {
        return CacheType(value: "max-stale=\(seconds)")
    }
    static func minFresh(_ seconds: Int) -> CacheType {
        return CacheType(value: "min-fresh=\(seconds)")
    }
}
