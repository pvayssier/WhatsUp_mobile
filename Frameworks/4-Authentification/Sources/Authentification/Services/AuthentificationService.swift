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
    var isLoading: Bool { get }
    func login(authentId: String, password: String) async -> Bool
    func createAccount(user: User, password: String) async -> Bool
}

enum AuthentificationError: Error {
    case jwtStorageError
}

public class AuthentificationService: AuthentificationServiceProtocol, ObservableObject {

    @Published public var user: User?

    @Published public var isLoading: Bool = false

    @Injected(\.userDefaultsManager) private var userDefaultsManager

    private var webDataAccess: AuthentificationWebDataAccessProtocol

    public init(webDataAccess: AuthentificationWebDataAccessProtocol) {
        self.webDataAccess = webDataAccess
    }

    public func createAccount(user userInformation: User, password: String) async -> Bool {
        isLoading = true
        do {
            let request = try await webDataAccess.createAccount(user: userInformation, password: password)
            self.user = User(id: request.user.id,
                             username: request.user.pseudo,
                             email: request.user.email,
                             phone: request.user.phone)
            isLoading = false
            return dataPersisted(user: user,jwt: request.token)
        } catch {
            debugPrint(error)
        }
        isLoading = false
        return false
    }

    public func login(authentId: String, password: String) async -> Bool {
        isLoading = true
        guard let request = try? await webDataAccess.login(authentId: authentId, password: password) else { return false }

        self.user = User(id: request.user.id,
                         username: request.user.pseudo,
                         email: request.user.email,
                         phone: request.user.phone)

        isLoading = false
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
