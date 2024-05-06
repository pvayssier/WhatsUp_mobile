//
//  SingleConversationViewState.swift
//
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI
import Factory
import Models

public protocol SingleConversationViewStateProtocol: ObservableObject {
    var groupName: String { get }
    var formatLastMessage: String { get }
    var formatDate: String { get }
    var picture: Image? { get }
}

final public class SingleConversationViewState: SingleConversationViewStateProtocol {

    @Published public var picture: Image?

    public var groupName: String = ""
    public var formatLastMessage: String = ""
    public var formatDate: String = ""

    public init(conversation: Conversation) {
        self.groupName = conversation.name
        if let lastMessage = conversation.lastMessage, let user = Container.shared.userDefaultsManager().user {
            if lastMessage.senderId == user.id {
                let senderName = "You"
                self.formatLastMessage = "\(senderName): \(lastMessage.content)"
            } else {
                let senderName = conversation.users.first(where: { $0.id == lastMessage.senderId })?.username
                self.formatLastMessage = "\(senderName ?? "Undefined User"): \(lastMessage.content)"
            }
        } else {
            self.formatLastMessage = "No message yet"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        if Calendar.current.isDateInToday(conversation.updateAt) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            self.formatDate = dateFormatter.string(from: conversation.updateAt)
        } else {
            self.formatDate = dateFormatter.string(from: conversation.updateAt)
        }

        Task {
            await setupPicture(with: conversation.pictureURL)
        }
    }

    @MainActor
    private func setupPicture(with url: URL?) {
        guard let url else { return }
        Task {
            self.picture = await Image.loadAsync(from: url, defaultImage: Image(systemName: "person.2.fill"))
        }
    }
}
