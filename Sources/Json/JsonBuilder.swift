//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

@_functionBuilder
internal struct JsonBuilder {
    static func buildBlock(_ props: JsonProperty...) -> JsonProperty {
        return JsonProperty(key: "root", value: props)
    }
    
    static func buildBlock() -> JsonProperty {
        return JsonProperty(key: "root", value: [])
    }
}
