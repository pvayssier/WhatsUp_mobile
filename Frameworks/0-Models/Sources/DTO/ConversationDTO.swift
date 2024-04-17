//
//  ConversationDTO.swift
//
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation

public struct ConversationDTO: Codable {
    public init(id: String,
                name: String,
                users: [UserDTO],
                lastMessage: MessageDTO?, 
                createAt: String,
                updateAt: String,
                pictureURL: URL?) {
        self.id = id
        self.name = name
        self.users = users
        self.lastMessage = lastMessage
        self.createAt = createAt
        self.updateAt = updateAt
        self.pictureURL = pictureURL
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case users
        case lastMessage = "last_message"
        case createAt = "created_at"
        case updateAt = "updated_at"
        case pictureURL = "group_picture"
    }

    public let id: String
    public let name: String
    public let users: [UserDTO]
    public let lastMessage: MessageDTO?
    public let createAt: String
    public let updateAt: String
    public let pictureURL: URL?
}
