//
//  Form.File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public extension Form {
    struct File: FormParam {
        private let path: Url
        private let fileManager: FileManager
        private let mediaType: MediaType

        public init(_ url: Url, withType mediaType: MediaType, _ fileManager: FileManager = .default) {
            self.path = url
            self.fileManager = fileManager
            self.mediaType = mediaType
        }

        public init(_ url: Url, _ fileManager: FileManager = .default) throws {
            fatalError("init(_:, _:) throw not implemented")
        }

        public func buildData(_ data: inout Foundation.Data, with boundary: String) {
            guard
                let fileData = fileManager.contents(atPath: path.absoluteString),
                let fileName = path.absoluteString.split(separator: "/").last
            else {
                fatalError("\(path.absoluteString) is not a file or it doesn't contains a valid file name")
            }

            data.append(header(boundary))
            data.append(disposition(fileName, withType: mediaType))
            data.append(Foundation.Data("\(breakLine)".utf8))
            data.append(fileData)
        }
    }
}
