//
//  ChatConversationWebDataAccess.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation
import Models
import Tools

protocol ChatConversationWebDataAccessProtocol {
    func fetchMessages(conversationId: String) async throws -> ChatConversationDTO
}

final class ChatConversationWebDataAccess: ChatConversationWebDataAccessProtocol {
    func fetchMessages(conversationId: String) async throws -> ChatConversationDTO {
        let resource = Resource<ChatConversationDTO>(endpoint: .chatConversation(id: conversationId),
                                                     method: .get(.none),
                                                     modelType: ChatConversationDTO.self,
                                                     isAuthentified: true)

        return try await HTTPClient.shared.load(resource)
    }
}
