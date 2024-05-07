//
//  SendTokenDTO.swift
//  
//
//  Created by Paul VAYSSIER on 07/05/2024.
//

import Foundation

public struct SendTokenDTO: Codable {
    let token: String

    public init(token: String) {
        self.token = token
    }
}
