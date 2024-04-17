//
//  ConversationsListService.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Models
import Tools

public protocol ConversationsListServiceProtocol {
    func fetchConversations() async -> [Conversation]
}

final public class ConversationsListService: ConversationsListServiceProtocol {

    private let webDataAccess: ConversationsListWebDataAccessProtocol

    public init(webDataAccess: ConversationsListWebDataAccessProtocol) {
        self.webDataAccess = webDataAccess
    }

    public func fetchConversations() async -> [Conversation] {
        do {
            let conversationsDTO = try await webDataAccess.fetchConversations()
            return conversationsDTO.map { conversationDTO -> Conversation in
                let users = conversationDTO.users.map {
                    User(id: $0.id,
                         username: $0.pseudo,
                         email: $0.email,
                         phone: $0.phone)
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter.locale = Calendar.current.locale
                formatter.timeZone = Calendar.current.timeZone

                var lastMessage: Message? = nil
                if let message = conversationDTO.lastMessage,
                   let dateFormat = formatter.date(from: message.createdAt) {
                    lastMessage = Message(id: message.id,
                                          content: message.content,
                                          senderId: message.senderId,
                                          createdAt: dateFormat)
                }

                let createdAtDate = formatter.date(from: conversationDTO.createAt) ?? Date()
                let updatedAtDate = formatter.date(from: conversationDTO.updateAt) ?? Date()


                return Conversation(id: conversationDTO.id,
                                    name: conversationDTO.name,
                                    users: users,
                                    lastMessage: lastMessage,
                                    createdAt: createdAtDate,
                                    updateAt: updatedAtDate,
                                    pictureURL: conversationDTO.pictureURL)
            }
        } catch {
            print(error)
            return []
        }
    }
}