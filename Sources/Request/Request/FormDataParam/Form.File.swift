//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public extension Form {
    struct File: RequestParam, FormDataParam {
        private let path: Url
        private let fileManager: FileManager
        private let mime: String

        public init(_ mediaType: MediaType, _ url: Url, _ fileManager: FileManager = .default) {
            self.path = url
            self.fileManager = fileManager
            self.mime = mediaType.rawValue
        }

        public init(mime: String, _ url: Url, _ fileManager: FileManager = .default) {
            self.path = url
            self.fileManager = fileManager
            self.mime = mime
        }

        func buildData(_ data: inout Foundation.Data, with boundary: String) {
            guard
                let fileData = fileManager.contents(atPath: path.absoluteString),
                let fileName = path.absoluteString.split(separator: "/").last
            else {
                fatalError()
            }

            data.append(header)
            data.append(disposition(fileName, mime: mime))
            data.append(Foundation.Data("\(breakLine)".utf8))
            data.append(fileData)
        }
    }
}
