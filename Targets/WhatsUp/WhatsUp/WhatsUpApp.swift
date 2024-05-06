//
//  WhatsUpApp.swift
//  WhatsUp
//
//  Created by Paul VAYSSIER on 08/04/2024.
//

import SwiftUI
import Authentification

@main
struct WhatsUpApp: App {

    var body: some Scene {
        WindowGroup {
            AuthentificationView(viewModel: AuthViewModel(viewState: AuthViewState(authType: .login)))
        }
    }
}

#if DEBUG
#Preview {
    AuthentificationView(viewModel: AuthViewModel(viewState: AuthViewState(authType: .login)))
}
#endif
