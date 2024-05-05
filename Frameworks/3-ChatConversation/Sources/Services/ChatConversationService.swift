//
//  ChatConversationService.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation
import Models

protocol ChatConversationServiceProtocol {
    func fetchMessages(conversationId: String) async throws -> ChatConversation
    func reportMessage(messageId: String) async -> Bool
}

final class ChatConversationService: ChatConversationServiceProtocol {
    private let webDataAccess: ChatConversationWebDataAccessProtocol

    init(webDataAccess: ChatConversationWebDataAccessProtocol){
        self.webDataAccess = webDataAccess
    }

    func fetchMessages(conversationId: String) async throws -> ChatConversation {
        let chatConversationDTO = try await webDataAccess.fetchMessages(conversationId: conversationId)
        return ChatConversation(dto: chatConversationDTO)
    }

    func reportMessage(messageId: String) async -> Bool {
        let ticket = try? await webDataAccess.reportMessage(messageId: messageId)
        return ticket != nil
    }
}
