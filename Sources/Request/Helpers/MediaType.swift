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

    case text = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case javascript = "text/javascript"

    case gif = "image/git"
    case png = "image/png"
    case jpeg = "image/jpeg"
    case bmp = "image/bmp"
    case webp = "image/webp"

    case midi = "audio/midi"
    case mpeg = "audio/mpeg"
    case webmAudio = "audio/webm"
    case oggAudio = "audio/ogg"
    case wav = "audio/wav"

    case webmVideo = "video/webm"
    case oggVideo = "video/ogg"

    case pdf = "application/pdf"

}
