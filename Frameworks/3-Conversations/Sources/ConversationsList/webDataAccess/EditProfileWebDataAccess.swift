//
//  EditProfileWebDataAccess.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import Foundation
import Models
import Tools

protocol EditProfileWebDataAccessProtocol {
    func updateProfile(userId: String,
                       dto: UpdateProfileDTO) async throws -> UserDTO
    func deleteProfile() async throws -> Bool
}

final class EditProfileWebDataAccess: EditProfileWebDataAccessProtocol {

    func updateProfile(userId: String,
                       dto: UpdateProfileDTO) async throws -> UserDTO {
        var multipart = MultipartRequest()

        multipart.add(key: "pseudo", value: dto.pseudo)

        multipart.add(key: "email", value: dto.email)

        multipart.add(key: "phone", value: dto.phone)

        if let data = dto.picture {
            multipart.add(key: "file",
                          fileName: "file.png",
                          fileMimeType: "image/png",
                          fileData: data)
        }

        let resource = Resource<UserDTO>(endpoint: .updateProfile(id: userId),
                                         method: .patch(multipart.httpBody),
                                         contentType: multipart.httpContentTypeHeadeValue,
                                         modelType: UserDTO.self,
                                         isAuthentified: true)

        return try await HTTPClient.shared.load(resource)
    }

    func deleteProfile() async throws -> Bool {
        let resource = Resource<UserDTO>(endpoint: .deleteUser,
                                         method: .delete,
                                         modelType: UserDTO.self,
                                         isAuthentified: true)

        _ = try await HTTPClient.shared.load(resource)
        return true
    }
}
