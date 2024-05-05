//
//  Container+ConversationsList.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Factory
import Tools

extension Container {
    public var conversationsListService: Factory<ConversationsListServiceProtocol> {
        self {
            let webDataAccess = ConversationsListWebDataAccess()
            return ConversationsListService(webDataAccess: webDataAccess)
        }
    }

    public var editProfileService: Factory<EditProfileServiceProtocol> {
        self {
            let webDataAccess = EditProfileWebDataAccess()
            return EditProfileService(webDataAccess: webDataAccess)
        }
    }

    public var userDefaultsManager: Factory<UserDefaultsManagerProtocol> {
        self { UserDefaultsManager() }
    }
}
