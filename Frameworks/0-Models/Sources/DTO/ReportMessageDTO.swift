//
//  ReportMessageDTO.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import Foundation

public struct ReportMessageDTO: Codable {
    public let messageId: String

    public init(messageId: String) {
        self.messageId = messageId
    }

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
    }
}
