//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

@_functionBuilder
public struct JsonBuilder {
    public static func buildBlock(_ props: (String, Any)...) -> [(String, Any)] {
        return props
    }
}
