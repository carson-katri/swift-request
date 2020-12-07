//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

/// A parameter used to build the `Request`
public protocol RequestParam {
    func buildParam(_ request: inout URLRequest)
}
