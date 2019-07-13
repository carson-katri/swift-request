//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation
import SwiftUI

/// The key-value pairs in a `Json` object
public struct JsonProperty {
    var key: String
    var value: Any?
    
    public init(key: String, value: Any?) {
        self.key = key
        self.value = value
    }
    
    /// Retrieves the value as a non-optional `String`
    var string: String {
        return value as? String ?? ""
    }
    
    /// Retrieves the value as a non-optional `Double`
    var double: Double {
        return value as? Double ?? 0.0
    }
    /// Retrieves the value as a non-optional `Int`
    var int: Int {
        return value as? Int ?? 0
    }
    
    /// Retrieves the value as a non-optional `Json` object
    var json: Json {
        get {
            let props = value as? [JsonProperty] ?? [JsonProperty]()
            var json = Json()
            json.properties = props
            return json
        }
    }
    
    /// Retrieves the value as a non-optional `JsonProperty`
    var property: JsonProperty {
        get {
            return value as? JsonProperty ?? JsonProperty(key: "", value: nil)
        }
    }
    
    subscript(index: Int) -> JsonProperty {
        return (value as! [JsonProperty])[index]
    }
    
    subscript(keyParam: String) -> JsonProperty {
        return (value as! [JsonProperty]).filter({ $0.key == keyParam }).first!
    }
}
