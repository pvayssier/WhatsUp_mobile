//
//  EditProfileService.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import Foundation
import Models

public protocol EditProfileServiceProtocol {
    func updateProfile(userId: String,
                       username: String,
                       email: String,
                       phone: String,
                       picture: Data?) async throws -> UserDTO
    func deleteProfile() async throws -> Bool
}

final class EditProfileService: EditProfileServiceProtocol {

    private let webDataAccess: EditProfileWebDataAccessProtocol

    init(webDataAccess: EditProfileWebDataAccessProtocol) {
        self.webDataAccess = webDataAccess
    }

    func updateProfile(userId: String,
                       username: String,
                       email: String,
                       phone: String,
                       picture: Data?) async throws -> UserDTO {

        let userDTO = UpdateProfileDTO(pseudo: username,
                                       email: email,
                                       phone: phone,
                                       picture: picture)
        return try await webDataAccess.updateProfile(userId: userId, dto: userDTO)
    }

    func deleteProfile() async throws -> Bool {
        try await webDataAccess.deleteProfile()
    }
}

