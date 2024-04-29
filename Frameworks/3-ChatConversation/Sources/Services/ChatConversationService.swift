//
//  ChatConversationService.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation
import Models

protocol ChatConversationServiceProtocol {
    func fetchMessages(conversationId: String) async throws -> ChatConversation
}

final class ChatConversationService: ChatConversationServiceProtocol {
    private let webDataAccess: ChatConversationWebDataAccessProtocol

    init(webDataAccess: ChatConversationWebDataAccessProtocol){
        self.webDataAccess = webDataAccess
    }

    func fetchMessages(conversationId: String) async throws -> ChatConversation {
        let chatConversationDTO = try await webDataAccess.fetchMessages(conversationId: conversationId)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Calendar.current.locale
        formatter.timeZone = Calendar.current.timeZone

        let users = chatConversationDTO.users.map { userDTO in
            return User(id: userDTO.id,
                        username: userDTO.pseudo,
                        email: userDTO.email,
                        phone: userDTO.phone,
                        pictureUrl: URL(string: userDTO.pictureUrl ?? ""))
        }

        let messages = chatConversationDTO.messages.map { messageDTO -> Message in

            let createdAtDate = formatter.date(from: messageDTO.createdAt) ?? Date()

            return Message(id: messageDTO.id,
                           content: messageDTO.content,
                           senderId: messageDTO.senderId,
                           createdAt: createdAtDate)
        }

        let pictureURL = chatConversationDTO.pictureURL.flatMap { URL(string: $0) }

        let conv = ChatConversation(id: chatConversationDTO.id,
                                    name: chatConversationDTO.name,
                                    messages: messages,
                                    users: users,
                                    pictureURL: pictureURL)
        return conv
    }
}
