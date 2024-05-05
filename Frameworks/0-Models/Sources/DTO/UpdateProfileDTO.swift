//
//  UpdateProfileDTO.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import Foundation

public struct UpdateProfileDTO: Codable {
    public let pseudo: String
    public let email: String
    public let phone: String
    public let picture: Data?

    public init(pseudo: String, email: String, phone: String, picture: Data?) {
        self.pseudo = pseudo
        self.email = email
        self.phone = phone
        self.picture = picture
    }

    enum CodingKeys: String, CodingKey {
        case pseudo
        case email
        case phone
        case picture
    }
}
