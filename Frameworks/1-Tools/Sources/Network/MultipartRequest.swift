//
//  MultipartRequest.swift
//  
//
//  Created by Paul VAYSSIER on 22/04/2024.
//

import Foundation

public struct MultipartRequest {

    public let boundary: String

    private let separator: String = "\r\n"
    private var data: NSMutableData

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }

    private mutating func appendBoundarySeparator() {
        data.appendString("--\(boundary)\(separator)")
    }

    private mutating func appendSeparator() {
        data.appendString(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.appendString(disposition(key) + separator)
        appendSeparator()
        data.appendString(value + separator)
    }

    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.appendString(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.appendString("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public var httpBody: Data {
        data.appendString("--\(boundary)--")
        return data as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
