//
//  CreateConversationDTO.swift
//  
//
//  Created by Paul VAYSSIER on 21/04/2024.
//

import Foundation

public struct CreateConversationDTO: Codable {
    public init(name: String?,
                users: [String],
                pictureData: Data?) {
        self.name = name
        self.users = users
        self.pictureData = pictureData
    }

    enum CodingKeys: String, CodingKey {
        case name
        case users
        case pictureData = "group_picture"
    }

    public let name: String?
    public let users: [String]
    public let pictureData: Data?
}
