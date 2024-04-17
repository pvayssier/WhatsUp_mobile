//
//  Conversation.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation

public struct Conversation: Codable, Identifiable, Equatable {
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    public init(id: String,
                name: String,
                users: [User],
                lastMessage: Message?,
                createdAt: Date,
                updateAt: Date,
                pictureURL: URL? = nil) {
        self.id = id
        self.name = name
        self.users = users
        self.lastMessage = lastMessage
        self.createdAt = createdAt
        self.updateAt = updateAt
        self.pictureURL = pictureURL
    }

    public let id: String
    public let name: String
    public let users: [User]
    public let lastMessage: Message?
    public let createdAt: Date
    public let updateAt: Date
    public let pictureURL: URL?
}
