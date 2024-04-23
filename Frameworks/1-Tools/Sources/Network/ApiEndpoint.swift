//
//  ApiEndpoint.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public enum ApiEndpoint {
    case register
    case login
    case myConversations
    case createConversation
    case chatConversation(id: String)

    var path: String {
        switch self {
        case .register:
            return "users/register"
        case .login:
            return "users/login"
        case .myConversations:
            return "conversations/"
        case .createConversation:
            return "conversations/create"
        case .chatConversation(let id):
            return "conversations/\(id)"
        }
    }

    static private let baseURL = UserDefaultsManager().baseURL ?? "http://localhost:3000/"

    static func endpointURL(for endpoint: ApiEndpoint) -> URL {
        guard let url = URL(string: baseURL + endpoint.path) else {
            fatalError("Invalid URL")
        }
        return url
    }
}
