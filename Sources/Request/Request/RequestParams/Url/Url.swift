//
//  File.swift
//  
//
//  Created by Carson Katri on 6/30/19.
//

import Foundation

/// Sets the URL of the `Request`.
/// - Precondition: Only use one URL in your `Request`. To group or chain requests, use a `RequestGroup` or `RequestChain`.
public struct Url: RequestParam, Codable {
    private let type: ProtocolType?
    fileprivate let path: String
    
    public init(_ path: String) {
        self.type = nil
        self.path = path
    }
    
    public init(`protocol` type: ProtocolType, url: String) {
        self.type = type
        self.path = url
    }

    public func buildParam(_ request: inout URLRequest) {
        request.url = URL(string: absoluteString)
    }

    internal var absoluteString: String {
        if let type = type {
            return "\(type.rawValue)://\(path)"
        }

        return path
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(absoluteString)
    }
}

extension Url: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.absoluteString == rhs.absoluteString
    }
}

public extension Url {
    func append(_ string: String) -> Url {
        if let type = type {
            return .init(protocol: type, url: "\(path)\(string)")
        }

        return .init("\(path)\(string)")
    }
}

public func + (_ url: Url, _ complementary: String) -> Url {
    url.append(complementary)
}

public func + (_ lhs: Url, _ rhs: Url) -> Url {
    lhs.append(rhs.path)
}
