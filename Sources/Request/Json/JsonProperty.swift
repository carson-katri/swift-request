//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation
import SwiftUI

public struct JsonProperty {
    var key: String
    var value: Any?
    
    public init(key: String, value: Any?) {
        self.key = key
        self.value = value
    }
    
    var string: String {
        return value as? String ?? ""
    }
    
    var double: Double {
        return value as? Double ?? 0.0
    }
    var int: Int {
        return value as? Int ?? 0
    }
    
    var json: Json {
        get {
            let props = value as? [JsonProperty] ?? [JsonProperty]()
            var json = Json()
            json.properties = props
            return json
        }
    }
    
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
