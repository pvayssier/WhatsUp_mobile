//
//  SendMessageDTO.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation

public struct SendMessageDTO: Codable {

    public init(content: String, senderId: String, conversationId: String) {
        self.content = content
        self.senderId = senderId
        self.conversationId = conversationId
    }

    public let content: String
    public let senderId: String
    public let conversationId: String

    enum CodingKeys: String, CodingKey {
        case content
        case senderId = "sender_id"
        case conversationId = "conversation_id"
    }
}
