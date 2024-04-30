//
//  ChatConversation.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation

public struct ChatConversation {
    public init(id: String, name: String, messages: [Message], users: [User], pictureURL: URL?) {
        self.id = id
        self.name = name
        self.messages = messages
        self.users = users
        self.pictureURL = pictureURL
    }

    public let id: String
    public let name: String
    public var messages: [Message]
    public let users: [User]
    public let pictureURL: URL?
}
