//
//  File.swift
//  
//
//  Created by brennobemoura on 04/02/21.
//

import Foundation

public extension Form {
    struct Value<Element>: FormParam {
        private let key: String
        private let element: Element

        /// Creates a multipart form data body from `Encodable` value.
        ///
        /// - Parameter key: The key being sent. Example: `name`
        /// - Parameter element: The element that will be inserted in form data body. Example: `test`
        ///
        public init(key: String, _ element: Element) {
            self.key = key
            self.element = element
        }

        public func buildData(_ data: inout Foundation.Data, with boundary: String) {
            data.append(header(boundary))
            data.append(disposition(key))
            data.append(Foundation.Data("\(breakLine)".utf8))
            data.append(Foundation.Data("\(element)".utf8))
        }
    }
}
