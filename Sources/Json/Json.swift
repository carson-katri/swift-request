//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

/// A representation of a JSON object that is more robust than `[String:Any]`
///
/// `Json` is used as the response type in the `onJson` callback on a `Request` object.
///
/// You can create `Json` by parsing a `String` or `Data`:
///
///     Json.Parse("{\"firstName\":\"Carson\"}")
///     Json.Parse("{\"firstName\":\"Carson\"}".data(using: .utf8))
///
/// Or you can build `Json` by hand:
///
///     Json {
///         JsonProperty(key: "firstName", value: "Carson")
///     }
///
/// You can subscript `Json` as you would expect:
///
///     myJson["firstName"].string // "Carson"
///     myComplexJson[0]["nestedJson"]["id"].int
public struct Json {
    public var properties: [JsonProperty]
    
    /// Encodes the `Json` as `Data`
    public var data: Data {
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
    /// Encodes the `Json` as a `String`
    public var string: String {
        return String(data: self.data, encoding: .utf8) ?? ""
    }
    
    public init(@JsonBuilder builder: () -> JsonProperty) {
        if builder().value is [JsonProperty] {
            self.properties = builder().value as! [JsonProperty]
        } else {
            self.properties = [builder()]
        }
    }
    
    public init() {
        self.properties = []
    }
    
    /// Parses `Json` from a `String`
    ///
    /// It can handle JSON objects, and arrays of JSON objects.
    ///
    ///     Json.Parse("{\"firstName\":\"Carson\"}")
    ///
    /// - Parameter string: the JSON string to be parsed
    public static func Parse(_ string: String) -> Json? {
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
    
    /// Parses `Json` from a `Data`
    ///
    /// This creates the `String` for you, and is really just a convenience version of `Parse` that accepts a `String`
    ///
    ///     Json.Parse("{\"firstName\":\"Carson\"}".data(using: .utf8))
    public static func Parse(_ data: Data) -> Json? {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return self.Parse(string)
    }
    
    /*public static func Decode<T>(_ type: T.Type, data: Data) -> T where T: Decodable {
        return try! JSONDecoder().decode(type, from: data)
    }*/
    
    public subscript(index: Int) -> JsonProperty {
        return properties[index]
    }
    
    public subscript(key: String) -> JsonProperty {
        return properties.filter({ $0.key == key }).first!
    }
}
