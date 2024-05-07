//
//  AppDelegate.swift
//  WhatsUpApp
//
//  Created by Paul VAYSSIER on 07/05/2024.
//

import SwiftUI
import Tools
import Models
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()

        if application.isRegisteredForRemoteNotifications {
            sendDeviceTokenToServer(token: token)
        }
    }

    func sendDeviceTokenToServer(token: String) {
        let sendTokenDTO = SendTokenDTO(token: token)
        SendTokenWebDataAccess().sendToken(dto: sendTokenDTO)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Gérer l'échec de l'enregistrement
        print("Failed to register: \(error)")
    }
}
