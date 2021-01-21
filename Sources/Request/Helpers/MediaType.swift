//
//  ContentType.swift
//  PackageTests
//
//  Created by Carson Katri on 7/2/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

/// A MIME type to be used with the `Accept` and `Content-Type` headers.
public enum MediaType: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    case json
    case xml

    case text
    case html
    case css
    case javascript

    case gif
    case png
    case jpeg
    case bmp
    case webp

    case midi
    case mpeg
    case wav

    case pdf

    case custom(String)

    public init(stringLiteral value: String) {
        self = .custom(value)
    }
}

extension MediaType {
    public var rawValue: String {
        switch self {
        case .json:         return "application/json"
        case .xml:          return "application/xml"

        case .text:         return "text/plain"
        case .html:         return "text/html"
        case .css:          return "text/css"
        case .javascript:   return "text/javascript"

        case .gif:          return "image/gif"
        case .png:          return "image/png"
        case .jpeg:         return "image/jpeg"
        case .bmp:          return "image/bmp"
        case .webp:         return "image/webp"

        case .midi:         return "audio/midi"
        case .mpeg:         return "audio/mpeg"
        case .wav:          return "audio/wav"

        case .pdf:          return "application/pdf"

        case .custom(let string):
            return string
        }
    }
}
