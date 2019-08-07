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
///     Json("{\"firstName\":\"Carson\"}")
///     Json("{\"firstName\":\"Carson\"}".data(using: .utf8))
///
/// Or you can build `Json` by hand:
///
///     Json {
///         ("firstName", "Carson")
///     }
///
/// You can subscript `Json` as you would expect:
///
///     myJson["firstName"].string // "Carson"
///     myComplexJson[0]["nestedJson"]["id"].int
///
/// You can also subscript with commas:
///
///     myJson[0, "nestedJson", "id"].int
///
/// This is the same as:
///
///     myJson[0]["nestedJson"]["id"].int
@dynamicMemberLookup
public struct Json {
    
    var jsonData: Any
    
    public init() {
        self.jsonData = [:]
    }
    
    /// Parse a JSON string using `JSONSerialization.jsonObject` to create the `Json`
    public init(_ parse: String) throws {
        try self.init(parse.data(using: .utf8)!)
    }
    
    /// Create `Json` from data
    public init(_ data: Data) throws {
        self.jsonData = try JSONSerialization.jsonObject(with: data)
    }
    
    // MARK: Subscripts
    public subscript(_ sub: JsonSubscript) -> Self {
        get {
            var json = Self()
            switch sub.jsonKey {
                case .key(let s):
                    json.jsonData = (jsonData as! [String: Any])[s]!
                case .index(let i):
                    json.jsonData = (jsonData as! [Any])[i]
            }
            return json
        }
        set {
            switch sub.jsonKey {
                case .key(let s):
                    var cast = jsonData as! [String: Any]
                    cast[s] = newValue.jsonData
                    jsonData = cast
                case .index(let i):
                    var cast = jsonData as! [Any]
                    cast[i] = newValue.jsonData
                    jsonData = cast
            }
        }
    }
    public subscript(_ subs: [JsonSubscript]) -> Self {
        get {
            subs.reduce(self) { $0[$1] }
        }
        set {
            switch subs.count {
                case 0:
                    return
                case 1:
                    self[subs.first!] = newValue
                default:
                    var newSubs = subs
                    newSubs.remove(at: 0)
                    var json = self[subs.first!]
                    json[newSubs] = newValue
            }
        }
    }
    public subscript(_ subs: JsonSubscript...) -> Self {
        get {
            self[subs]
        }
        set {
            self[subs] = newValue
        }
    }
    public subscript(dynamicMember member: String) -> Self {
        get {
            self[member]
        }
        set {
            self[member] = newValue
        }
    }
    
    // MARK:  Accessors
    func accessValue<T>(_ defaultValue: T) -> T {
        accessOptional(T.self) ?? defaultValue
    }
    
    func accessOptional<T>(_ type: T.Type) -> T? {
        jsonData as? T
    }
    
    /// The stored value of the `Json`
    public var value: Any {
        jsonData
    }
    
    /// The data as a non-optional `String`
    public var string: String {
        accessValue("")
    }
    /// The data as an optional `String`
    public var stringOptional: String? {
        accessOptional(String.self)
    }

    /// The data as a non-optional `Int`
    public var int: Int {
        accessValue(0)
    }
    /// The data as an optional `Int`
    public var intOptional: Int? {
        accessOptional(Int.self)
    }

    /// The data as a non-optional `Double`
    public var double: Double {
        accessValue(0.0)
    }
    /// The data as an optional `Double`
    public var doubleOptional: Double? {
        accessOptional(Double.self)
    }
    
    /// The data as a non-optional `Bool`
    public var bool: Bool {
        accessValue(false)
    }
    /// The data as an optional `Bool`
    public var boolOptional: Bool? {
        accessOptional(Bool.self)
    }
    
    /// The data as a non-optional `Array`
    public var array: [Any] {
        accessValue([])
    }
    /// The data as an optional `Array`
    public var arrayOptional: [Any]? {
        accessOptional([Any].self)
    }
    /// The number of elements in the data
    public var count: Int {
        array.count
    }
}
