//
//  UserDefaultsManager.swift
//  
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import Foundation
import Models

public protocol UserDefaultsProtocol {

    func value(forKey key: String) -> Any?
    func integer(forKey defaultName: String) -> Int
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func object(forKey defaultName: String) -> Any?

    func removeObject(forKey defaultName: String)

    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)

}

public struct FeedsRss: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public let url: URL

    public init(id: UUID = UUID(), name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }
}

extension UserDefaults: UserDefaultsProtocol {}

public protocol UserDefaultsManagerProtocol: AnyObject {

    // MARK: - Properties
    var user: User? { get set }
    var baseURL: String? { get set }
}

public class UserDefaultsManager: UserDefaultsManagerProtocol {

    // MARK: - Enums
    enum Keys: String, CaseIterable {
        case user
        case baseURL
    }

    private let userDefaults: UserDefaultsProtocol

    public init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public var user: User? {
        get {
            do {
                let decoder = JSONDecoder()
                if let data = userDefaults.object(forKey: Keys.user.rawValue) as? Data {
                    let user = try decoder.decode(User.self, from: data)
                    return user
                } else {
                    return nil
                }
            } catch {
                debugPrint("Unable to Decode User (\(error))")
                return nil
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                userDefaults.set(data, forKey: Keys.user.rawValue)
            } catch {
                debugPrint("Unable to Encode User (\(error))")
            }
        }
    }

    public var baseURL: String? {
        get {
            return userDefaults.object(forKey: Keys.baseURL.rawValue) as? String
        }
        set {
            userDefaults.set(newValue, forKey: Keys.baseURL.rawValue)
        }
    }
}
