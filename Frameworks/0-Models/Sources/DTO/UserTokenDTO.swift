//
//  UserTokenDTO.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public struct UserTokenDTO: Codable {
    public let token: String
    public let user: UserDTO

    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case user
    }
}
