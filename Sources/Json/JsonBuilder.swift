//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

@resultBuilder
public struct JsonBuilder {
    public static func buildBlock(_ props: (String, Any)...) -> [(String, Any)] {
        return props
    }
}
