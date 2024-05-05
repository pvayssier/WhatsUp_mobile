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
    case reportMessage
    case chatConversation(id: String)
    case leaveConversation(id: String)
    case updateConversation(id: String)

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
        case .reportMessage:
            return "tickets/"
        case .chatConversation(let id):
            return "conversations/\(id)"
        case .leaveConversation(let id):
            return "conversations/\(id)/leave"
        case .updateConversation(let id):
            return "conversations/\(id)/modify"
        }
    }

    static private let baseURL = UserDefaultsManager().baseURL ?? "http://172.16.70.196:3000/"

    static public func endpointURL(for endpoint: ApiEndpoint) -> URL {
        guard let url = URL(string: baseURL + endpoint.path) else {
            fatalError("Invalid URL")
        }
        return url
    }
}
