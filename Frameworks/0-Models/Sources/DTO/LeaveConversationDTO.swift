//
//  LeaveConversationDTO.swift
//  
//
//  Created by Paul VAYSSIER on 30/04/2024.
//

import Foundation

public struct LeaveConversationDTO: Codable {
    public init(userId: String, conversationId: String) {
        self.userId = userId
        self.conversationId = conversationId
    }
    
    public let userId: String
    public let conversationId: String
}
