//
//  AuthentificationWebDataAccess.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Models
import Tools

public protocol AuthentificationWebDataAccessProtocol {
    func createAccount(user: User, password: String) async throws -> UserTokenDTO
    func login(phone: String, password: String) async throws -> UserTokenDTO
}

public class AuthentificationWebDataAccess: AuthentificationWebDataAccessProtocol {

    public func createAccount(user: User, password: String) async throws -> UserTokenDTO {
        let params = [
            "pseudo": user.username,
            "email": user.email,
            "phone": user.phone,
            "password": password
        ]

        guard let data = try? JSONEncoder().encode(params) else {
            throw NetworkError.badRequest
        }
        let resource = Resource<UserTokenDTO>(endpoint: .register,
                                              method: .post(data),
                                              modelType: UserTokenDTO.self)
        return try await HTTPClient.shared.load(resource)
    }

    public func login(phone: String, password: String) async throws -> UserTokenDTO {
        let params = [
            "phone": phone,
            "password": password
        ]

        guard let data = try? JSONEncoder().encode(params) else {
            throw NetworkError.badRequest
        }
        let resource = Resource<UserTokenDTO>(endpoint: .login,
                                              method: .post(data),
                                              modelType: UserTokenDTO.self)
        return try await HTTPClient.shared.load(resource)
    }
}
