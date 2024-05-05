//
//  AuthViewState.swift
//  
//
//  Created by Paul VAYSSIER on 09/04/2024.
//

import SwiftUI

public enum AuthType: String, CaseIterable {
    case login
    case register
    case authentified
}

public struct AuthViewState {
    public init(username: String = "",
         email: String = "",
         phone: String = "",
         password: String = "",
         authType: AuthType) {
        self.username = username
        self.email = email
        self.phone = phone
        self.password = password
        self.authType = authType
    }

    var username: String
    var email: String
    var phone: String
    var password: String
    var authType: AuthType
}
