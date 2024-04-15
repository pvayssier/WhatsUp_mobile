//
//  UserDTO.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public struct UserDTO: Codable {
    public let id: String
    public let pseudo: String
    public let email: String
    public let phone: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pseudo
        case email
        case phone
    }
}
