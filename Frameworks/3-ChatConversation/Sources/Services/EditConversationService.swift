//
//  EditConversationService.swift
//
//
//  Created by Paul VAYSSIER on 30/04/2024.
//

import Foundation
import Models
import Tools

protocol EditConversationServiceProtocol {
    func leaveConversation(conversationId: String) async -> Bool
    func deleteConversation(conversationId: String) async -> Bool
    func updateConversation(name: String?,
                            users: [String]?,
                            pictureData: Data?,
                            conversationId: String) async throws -> ChatConversation
}

final class EditConversationService: EditConversationServiceProtocol {
    private let dataAccess: EditConversationWebDataAccessProtocol

    public init(dataAccess: EditConversationWebDataAccessProtocol) {
        self.dataAccess = dataAccess
    }

    func leaveConversation(conversationId: String) async -> Bool {
        return await dataAccess.leaveConversation(conversationId: conversationId)
    }

    func deleteConversation(conversationId: String) async -> Bool {
        return await dataAccess.deleteConversation(conversationId: conversationId)
    }

    func updateConversation(name: String?,
                            users: [String]?,
                            pictureData: Data?,
                            conversationId: String) async throws -> ChatConversation {
        let updateConversationDTO = UpdateConversationDTO(id: conversationId,
                                                          name: name,
                                                          users: users,
                                                          pictureData: pictureData)
        let chatConversationDTO = try await dataAccess.updateConversation(conversation: updateConversationDTO)

        return ChatConversation(dto: chatConversationDTO)
    }
}
