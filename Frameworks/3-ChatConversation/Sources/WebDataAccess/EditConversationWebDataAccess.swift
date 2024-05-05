//
//  EditConversationWebDataAccess.swift
//  
//
//  Created by Paul VAYSSIER on 30/04/2024.
//

import Foundation
import Models
import Tools

protocol EditConversationWebDataAccessProtocol {
    func leaveConversation(conversationId: String) async -> Bool
    func deleteConversation(conversationId: String) async -> Bool
    func updateConversation(conversation: UpdateConversationDTO) async throws -> ChatConversationDTO
}

final class EditConversationWebDataAccess: EditConversationWebDataAccessProtocol {

    func leaveConversation(conversationId: String) async -> Bool {

        let resource = Resource<Bool>(endpoint: .leaveConversation(id:conversationId),
                                                      method: .patch(.none),
                                                      modelType: Bool.self,
                                                      isAuthentified: true)

        var isSucceed = false
        do {
            isSucceed = try await HTTPClient.shared.load(resource)
        } catch {
            debugPrint("Error: \(error)")
        }
        return isSucceed
    }

    func deleteConversation(conversationId: String) async -> Bool {
        
        let resource = Resource<Bool>(endpoint: .chatConversation(id:conversationId),
                                      method: .delete,
                                      modelType: Bool.self,
                                      isAuthentified: true)

        var isSucceed = false
        do {
            isSucceed = try await HTTPClient.shared.load(resource)
        } catch {
            debugPrint("Error: \(error)")
        }
        return isSucceed
    }

    func updateConversation(conversation: UpdateConversationDTO) async throws -> ChatConversationDTO {
        var multipart = MultipartRequest()
        if let name = conversation.name {
            multipart.add(key: "name", value: name)
        }

        if let users = conversation.users {
            users.forEach { user in
                multipart.add(key: "users[]", value: user)
            }
        }

        if let data = conversation.pictureData {
            multipart.add(key: "file",
                          fileName: "file.png",
                          fileMimeType: "image/png",
                          fileData: data)
        }

        let resource = Resource<ChatConversationDTO>(endpoint: .updateConversation(id: conversation.id),
                                                     method: .patch(multipart.httpBody),
                                                     contentType: multipart.httpContentTypeHeadeValue,
                                                     modelType: ChatConversationDTO.self,
                                                     isAuthentified: true)
        return try await HTTPClient.shared.load(resource)
    }
}
