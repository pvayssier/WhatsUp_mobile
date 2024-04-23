//
//  Container+ChatConversation.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import Foundation
import Factory
import Tools

extension Container {
    var chatConversationService: Factory<ChatConversationServiceProtocol> {
        self {
            let webDataAccess: ChatConversationWebDataAccessProtocol = ChatConversationWebDataAccess()
            return ChatConversationService(webDataAccess: webDataAccess)
        }
    }

    var userDefaults: Factory<UserDefaultsManager> {
        self {
            return UserDefaultsManager()
        }
    }
}
