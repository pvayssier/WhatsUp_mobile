//
//  UpdateConversationDTO.swift
//  
//
//  Created by Paul VAYSSIER on 30/04/2024.
//


import Foundation

public struct UpdateConversationDTO: Codable {
    public init(id: String,
                name: String?,
                users: [String]?,
                pictureData: Data?) {
        self.id = id
        self.name = name
        self.users = users
        self.pictureData = pictureData
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case users
        case pictureData = "group_picture"
    }

    public let id: String
    public let name: String?
    public let users: [String]?
    public let pictureData: Data?
}
