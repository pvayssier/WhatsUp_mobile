//
//  MessageDTO.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation

public struct MessageDTO: Codable {
    public init(id: String, content: String, senderId: String, createdAt: String) {
        self.id = id
        self.content = content
        self.senderId = senderId
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case senderId = "sender_id"
        case createdAt = "created_at"
    }

    public let id: String
    public let content: String
    public let senderId: String
    public let createdAt: String
}
