//
//  Container+Authentification.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Factory
import Tools

extension Container {
    public var authentificationService: Factory<AuthentificationServiceProtocol> {
        self {
            let webDataAccess = AuthentificationWebDataAccess()
            return AuthentificationService(webDataAccess: webDataAccess)
        }
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }
    }
}
