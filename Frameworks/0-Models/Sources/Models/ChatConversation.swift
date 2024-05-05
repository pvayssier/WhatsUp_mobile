//
//  ChatConversation.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation

public struct ChatConversation {
    public init(id: String, 
                name: String,
                messages: [Message],
                users: [User],
                ownedBy: String,
                pictureURL: URL?) {
        self.id = id
        self.name = name
        self.messages = messages
        self.users = users
        self.ownedBy = ownedBy
        self.pictureURL = pictureURL
    }

    public let id: String
    public let name: String
    public var messages: [Message]
    public let users: [User]
    public let ownedBy: String
    public let pictureURL: URL?
}

extension ChatConversation {
    public init(dto: ChatConversationDTO) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Calendar.current.locale
        formatter.timeZone = Calendar.current.timeZone

        let users = dto.users.map { userDTO in
            return User(id: userDTO.id,
                        username: userDTO.pseudo,
                        email: userDTO.email,
                        phone: userDTO.phone,
                        pictureUrl: URL(string: userDTO.pictureUrl ?? ""))
        }

        let messages = dto.messages.map { messageDTO -> Message in

            let createdAtDate = formatter.date(from: messageDTO.createdAt) ?? Date()

            return Message(id: messageDTO.id,
                           content: messageDTO.content,
                           senderId: messageDTO.senderId,
                           createdAt: createdAtDate)
        }

        let pictureURL = dto.pictureURL.flatMap { URL(string: $0) }

        self =  .init(id: dto.id,
                      name: dto.name,
                      messages: messages,
                      users: users,
                      ownedBy: dto.ownedBy,
                      pictureURL: pictureURL)
    }
}
