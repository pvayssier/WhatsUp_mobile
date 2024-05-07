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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AuthentificationView(viewModel: AuthViewModel(viewState: AuthViewState(authType: .login)))
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    resetNotification()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    resetNotification()
                }
        }
    }

    private func resetNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    AuthentificationView(viewModel: AuthViewModel(viewState: AuthViewState(authType: .login)))
}
#endif
