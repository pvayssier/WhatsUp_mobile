//
//  PositionGroupMessage.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import Foundation
import Models

enum PositionInGroup {
    case idle
    case first
    case middle
    case last

    var padding: CGFloat {
        switch self {
        case .idle:
            return 12
        case .first:
            return 0
        case .middle:
            return 0
        case .last:
            return 12
        }
    }

    static func calculatePositionInGroup(previousMessage: Message?,
                                         message: Message?,
                                         nextMessage: Message?) -> PositionInGroup {
        if let previousMessage = previousMessage, let message = message, let nextMessage = nextMessage {
            if previousMessage.senderId != message.senderId && message.senderId == nextMessage.senderId {
                return .first
            } else if previousMessage.senderId == message.senderId && message.senderId == nextMessage.senderId {
                return .middle
            } else if previousMessage.senderId == message.senderId && message.senderId != nextMessage.senderId {
                return .last
            }
        } else if let previousMessage = previousMessage, let message = message {
            if previousMessage.senderId != message.senderId {
                return .idle
            } else {
                return .last
            }
        } else if let message = message, let nextMessage = nextMessage {
            if message.senderId == nextMessage.senderId {
                return .first
            } else {
                return .last
            }
        }
        return .idle
    }
}
