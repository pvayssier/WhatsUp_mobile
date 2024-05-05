//
//  AuthentificationService.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Factory
import Models
import Tools

public protocol AuthentificationServiceProtocol {
    var user: User? { get }
    func login(phone: String, password: String) async throws -> Bool
    func createAccount(user: User, password: String) async throws -> Bool
}

enum AuthentificationError: Error {
    case jwtStorageError
}

public class AuthentificationService: AuthentificationServiceProtocol, ObservableObject {

    @Published public var user: User?

    @Injected(\.userDefaultsManager) private var userDefaultsManager

    private var webDataAccess: AuthentificationWebDataAccessProtocol

    public init(webDataAccess: AuthentificationWebDataAccessProtocol) {
        self.webDataAccess = webDataAccess
    }

    public func createAccount(user userInformation: User, password: String) async throws -> Bool {
        let request = try await webDataAccess.createAccount(user: userInformation, password: password)
        self.user = User(id: request.user.id,
                         username: request.user.pseudo,
                         email: request.user.email,
                         phone: request.user.phone,
                         pictureUrl: URL(string: request.user.pictureUrl ?? ""))
        return dataPersisted(user: user,jwt: request.token)
    }

    public func login(phone: String, password: String) async throws -> Bool {
        let request = try await webDataAccess.login(phone: phone, password: password)

        self.user = User(id: request.user.id,
                         username: request.user.pseudo,
                         email: request.user.email,
                         phone: request.user.phone,
                         pictureUrl: URL(string: request.user.pictureUrl ?? ""))

        return dataPersisted(user: user,jwt: request.token)
    }

    private func dataPersisted(user: User?, jwt: String) -> Bool {
        userDefaultsManager.user = user
        return storeJWT(jwt) && userDefaultsManager.user == user
    }

    private func storeJWT(_ jwt: String) -> Bool {
        return KeychainHelper.storeJWT(jwt: jwt)
    }
}
