//
//  Container+ConversationsList.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Factory

extension Container {
    public var conversationsListService: Factory<ConversationsListServiceProtocol> {
        self {
            let webDataAccess = ConversationsListWebDataAccess()
            return ConversationsListService(webDataAccess: webDataAccess)
        }
    }
}
