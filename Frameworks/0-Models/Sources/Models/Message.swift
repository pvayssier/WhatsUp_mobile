//
//  Message.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation

public struct Message: Codable {
    public init(id: String, content: String, senderId: String, createdAt: Date) {
        self.id = id
        self.content = content
        self.senderId = senderId
        self.createdAt = createdAt
    }

    public let id: String
    public let content: String
    public let senderId: String
    public let createdAt: Date
}
