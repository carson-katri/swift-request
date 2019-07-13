//
//  ContentType.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

/// A MIME type to be used with the `Accept` and `Content-Type` headers.
public enum MediaType: String {
    case json = "application/json"
    case xml = "application/xml"
}
