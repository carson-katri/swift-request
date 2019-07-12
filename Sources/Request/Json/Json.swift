//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

public struct Json {
    var properties: [JsonProperty]
    var data: Data {
        var dict: [String:Any?] = [:]
        self.properties.forEach { prop in
            var value = prop.value
            if value is Json {
                value = (prop.value as! Json).string
            } else if value is JsonProperty {
                value = (prop.value as! JsonProperty).string
            } else if value is [JsonProperty] {
                value = (prop.value as! [JsonProperty]).map({ $0.string })
            }
            dict[prop.key] = value
        }
        return (try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)) ?? Data()
    }
    var string: String {
        return String(data: self.data, encoding: .utf8) ?? ""
    }
    
    public init(@JsonBuilder builder: () -> JsonProperty) {
        if builder().value is [JsonProperty] {
            self.properties = builder().value as! [JsonProperty]
        } else {
            self.properties = [builder()]
        }
    }
    
    init() {
        self.properties = []
    }
    
    static func Parse(_ string: String) -> Json? {
        var json = Json()
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: string.data(using: .utf8)!)
            if let jsonArray = jsonResponse as? [String: Any] {
                jsonArray.forEach { x in
                    if x.value is [String:Any] || x.value is [[String: Any]] {
                        let data = try! JSONSerialization.data(withJSONObject: x.value)
                        json.properties.append(JsonProperty(key: x.key, value: self.Parse(data)?.properties))
                    } else {
                        json.properties.append(JsonProperty(key: x.key, value: x.value))
                    }
                }
            } else if let jsonArray = jsonResponse as? [[String: Any]] {
                jsonArray.forEach { x in
                    var props: [JsonProperty] = []
                    x.forEach { y in
                        if y.value is [String:Any] || y.value is [[String: Any]] {
                            let data = try! JSONSerialization.data(withJSONObject: y.value)
                            props.append(JsonProperty(key: y.key, value: self.Parse(data)?.properties))
                        } else {
                            props.append(JsonProperty(key: y.key, value: y.value))
                        }
                    }
                    json.properties.append(JsonProperty(key: "", value: props))
                }
            } else {
                fatalError("Error parsing JSON; Doesn't conform to [String: Any] or [[String: Any]]")
            }
        } catch {
            print(error)
            return nil
        }
        return json
    }
    
    static func Parse(_ data: Data) -> Json? {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return self.Parse(string)
    }
    
    static func Decode<T>(_ type: T.Type, data: Data) -> T where T: Decodable {
        return try! JSONDecoder().decode(type, from: data)
    }
    
    subscript(index: Int) -> JsonProperty {
        return properties[index]
    }
    
    subscript(key: String) -> JsonProperty {
        return properties.filter({ $0.key == key }).first!
    }
}
