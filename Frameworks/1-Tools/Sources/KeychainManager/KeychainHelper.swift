//
//  KeychainHelper.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation 
import Security

public class KeychainHelper {
    private enum Constants {
        static let service = "com.paulvayssier.whatsupapp"
        static let key = "jwt"
    }

    public static func storeJWT(jwt: String) -> Bool {
        guard let data = jwt.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: Constants.key,
            kSecValueData as String: data
        ]
        if retrieveJWT() != nil {
            let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            return status == errSecSuccess
        }
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public static func retrieveJWT() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: Constants.key,
            kSecReturnData as String: kCFBooleanTrue as Any
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func deleteJWT() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.service,
            kSecAttrAccount as String: Constants.key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
