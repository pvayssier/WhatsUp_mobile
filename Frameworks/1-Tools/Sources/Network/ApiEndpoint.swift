//
//  ApiEndpoint.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation

public enum ApiEndpoint: String {
    case register = "users/register"
    case login = "users/login"
    case myConversations = "conversations/"
    case createConversation = "conversations/create"

    static private let baseURL = UserDefaultsManager().baseURL ?? "http://localhost:3000/"

    static func endpointURL(for endpoint: ApiEndpoint) -> URL {
        guard let url = URL(string: baseURL + endpoint.rawValue) else {
            fatalError("Invalid URL")
        }
        return url
    }
}
