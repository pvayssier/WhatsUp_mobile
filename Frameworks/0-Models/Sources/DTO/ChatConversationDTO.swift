//
//  ChatConversationDTO.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation

public struct ChatConversationDTO: Codable {
    public init(id: String,
                name: String,
                messages: [MessageDTO],
                users: [UserDTO],
                createdAt: String,
                updatedAt: String,
                createdBy: String,
                pictureURL: String?) {
        self.id = id
        self.name = name
        self.messages = messages
        self.users = users
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ownedBy = createdBy
        self.pictureURL = pictureURL
    }

    public let id: String
    public let name: String
    public let messages: [MessageDTO]
    public let users: [UserDTO]
    public let createdAt: String
    public let updatedAt: String
    public let ownedBy: String
    public let pictureURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case messages
        case users
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case ownedBy = "owned_by"
        case pictureURL = "picture_url"
    }

}
