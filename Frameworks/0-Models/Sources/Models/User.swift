//
//  User.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public struct User: Codable {
    public init(id: String, username: String, email: String, phone: String) {
        self.id = id
        self.username = username
        self.email = email
        self.phone = phone
    }

    public var id: String
    public var username: String
    public var email: String
    public var phone: String
}
