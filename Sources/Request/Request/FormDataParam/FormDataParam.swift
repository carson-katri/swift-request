//
//  File.swift
//  
//
//  Created by brennobemoura on 16/11/20.
//

import Foundation

protocol FormDataParam: RequestParam {
    func buildData(_ data: inout Data, with boundary: String)
}

extension FormDataParam {
    public func buildParam(_ request: inout URLRequest) {
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        buildData(&data, with: boundary)
        data.append(footer)

        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
    }
}

internal extension FormDataParam {
    private var boundary: String {
        "Boundary-\(NSUUID().uuidString)"
    }

    var breakLine: String {
        "\r\n"
    }

    var header: Data {
        .init("--\(boundary)\(breakLine)".utf8)
    }

    var middle: Data {
        .init("\(breakLine)--\(boundary)\(breakLine)".utf8)
    }

    var footer: Data {
        .init("\(breakLine)--\(boundary)--\(breakLine)".utf8)
    }

    func disposition<S>(_ fileName: S, mime: String) -> Data where S: StringProtocol {
        let name = fileName.split(separator: ".").dropLast().joined(separator: ".")

        var contents = Data()
        contents.append(Data("Content-Disposition: form-data; name=\(name); filename=\(fileName)\(breakLine)".utf8))
        contents.append(Data("Content-Type: \(mime)\(breakLine)".utf8))
        return contents
    }
}
