//
//  ConversationsListWebDataAccess.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Models
import Tools

public protocol ConversationsListWebDataAccessProtocol {
    func fetchConversations() async throws -> [ConversationDTO]
    func createConversation(conversation: CreateConversationDTO) async throws -> ConversationDTO
}

public class ConversationsListWebDataAccess: ConversationsListWebDataAccessProtocol {

    public func fetchConversations() async throws -> [ConversationDTO] {
        let resource = Resource<[ConversationDTO]>(endpoint: .myConversations,
                                                   method: .get(.none),
                                                   modelType: [ConversationDTO].self,
                                                   isAuthentified: true)
        return try await HTTPClient.shared.load(resource)
    }

    public func createConversation(conversation: CreateConversationDTO) async throws -> ConversationDTO {
        let conversationData = try JSONEncoder().encode(conversation)

        let resource = Resource<ConversationDTO>(endpoint: .createConversation,
                                                 method: .post(conversationData),
                                                 modelType: ConversationDTO.self,
                                                 isAuthentified: true)
        return try await HTTPClient.shared.load(resource)
    }
}
