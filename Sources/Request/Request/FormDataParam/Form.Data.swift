//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public extension Form {
    struct Data: RequestParam, FormDataParam {
        private let data: Foundation.Data
        private let fileName: String
        private let mime: String

        // fileName: image.jpg
        public init(_ fileName: String, _ mediaType: MediaType, _ data: Foundation.Data) {
            self.fileName = fileName
            self.data = data
            self.mime = mediaType.rawValue
        }

        public init(_ fileName: String, mime: String, _ data: Foundation.Data) {
            self.fileName = fileName
            self.data = data
            self.mime = mime
        }

        func buildData(_ data: inout Foundation.Data, with boundary: String) {
            data.append(header)
            data.append(disposition(fileName, mime: mime))
            data.append(Foundation.Data("\(breakLine)".utf8))
            data.append(self.data)
        }
    }
}
