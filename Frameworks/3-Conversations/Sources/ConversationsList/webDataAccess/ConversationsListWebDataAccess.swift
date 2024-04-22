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
        var multipart = MultipartRequest()
        if let name = conversation.name {
            multipart.add(key: "name", value: name)
        }

        conversation.users.forEach { user in
            multipart.add(key: "users[]", value: user)
        }

        if let data = conversation.pictureData {
            multipart.add(key: "file",
                          fileName: "file.png",
                          fileMimeType: "image/png",
                          fileData: data)
        }

        let resource = Resource<ConversationDTO>(endpoint: .createConversation,
                                                 method: .post(multipart.httpBody),
                                                 contentType: multipart.httpContentTypeHeadeValue,
                                                 modelType: ConversationDTO.self,
                                                 isAuthentified: true)
        return try await HTTPClient.shared.load(resource)
    }
}
