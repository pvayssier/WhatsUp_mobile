//
//  User.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public struct User: Codable, Equatable {
    public init(id: String, username: String, email: String, phone: String, pictureUrl: URL? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.phone = phone
        self.pictureUrl = pictureUrl
    }

    public let id: String
    public let username: String
    public let email: String
    public let phone: String
    public let pictureUrl: URL?
}
