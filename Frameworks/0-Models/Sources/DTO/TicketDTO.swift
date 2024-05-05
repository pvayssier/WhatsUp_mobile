//
//  TicketDTO.swift
//
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import Foundation

public struct TicketDTO: Codable {
    public let reporter: String
    public let content: String
    public let messageId: String
    public let conversationId: String
    public let senderUsername: String
    public let senderId: String

    public init(reporter: String,
                content: String,
                messageId: String,
                conversationId: String,
                senderUsername: String,
                senderId: String) {
        self.reporter = reporter
        self.content = content
        self.messageId = messageId
        self.conversationId = conversationId
        self.senderUsername = senderUsername
        self.senderId = senderId
    }

    enum CodingKeys: String, CodingKey {
        case reporter
        case content
        case messageId = "message_id"
        case conversationId = "conversation_id"
        case senderUsername = "sender_username"
        case senderId = "sender_id"
    }
}
