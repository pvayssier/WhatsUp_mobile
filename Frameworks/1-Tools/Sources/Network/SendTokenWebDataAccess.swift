//
//  SendTokenWebDataAccess.swift
//  
//
//  Created by Paul VAYSSIER on 07/05/2024.
//

import Foundation
import Models

final public  class SendTokenWebDataAccess {
    public init() { }

    public func sendToken(dto: SendTokenDTO) {
        guard let data = try? JSONEncoder().encode(dto) else { return }
        let resource = Resource<UserDTO>(endpoint: .sendDeviceToken,
                                         method: .post(data),
                                         modelType: UserDTO.self,
                                         isAuthentified: true)
        Task {
            do {
                _ = try await HTTPClient.shared.load(resource)
            } catch {
                debugPrint(error)
            }
        }
    }
}
