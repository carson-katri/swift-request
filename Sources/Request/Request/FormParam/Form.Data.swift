//
//  Form.Data.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

public extension Form {
    struct Data: FormParam {
        private let data: Foundation.Data
        private let fileName: String
        private let mediaType: MediaType

        /// Creates a multipart form data body from `Data`.
        ///
        /// - Parameter named: The name of the file being sent. Example: `image.jpg`
        ///
        public init(_ data: Foundation.Data, named fileName: String, withType mediaType: MediaType) {
            self.fileName = fileName
            self.data = data
            self.mediaType = mediaType
        }

        public func buildData(_ data: inout Foundation.Data, with boundary: String) {
            data.append(header(boundary))
            data.append(disposition(fileName, withType: mediaType))
            data.append(Foundation.Data("\(breakLine)".utf8))
            data.append(self.data)
        }
    }
}
