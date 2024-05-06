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
    var id: String { get }
    var groupName: String { get }
    var formatLastMessage: String { get }
    var formatDate: String { get }
    var picture: Image? { get }
    var isSkeleton: Bool { get }
}

final public class SingleConversationViewState: SingleConversationViewStateProtocol {

    @Published public var picture: Image?

    public var id: String = ""
    public var groupName: String = ""
    public var formatLastMessage: String = ""
    public var formatDate: String = ""
    public var isSkeleton: Bool = false

    public init(conversation: Conversation, isLoading: Bool = false) {
        self.isSkeleton = isLoading
        self.groupName = conversation.name
        self.id = conversation.id
        if let lastMessage = conversation.lastMessage, let user = Container.shared.userDefaultsManager().user {
            if lastMessage.senderId == user.id {
                let senderName = String(localized: "SingleConversation.you")
                self.formatLastMessage = "\(senderName): \(lastMessage.content)"
            } else {
                let senderName = conversation.users.first(where: { $0.id == lastMessage.senderId })?.username
                self.formatLastMessage = "\(senderName ?? String(localized: "SingleConversation.undefinedUser")): \(lastMessage.content)"
            }
        } else {
            self.formatLastMessage = String(localized: "SingleConversation.noMessage")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        if Calendar.current.isDateInToday(conversation.updateAt) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        self.formatDate = dateFormatter.string(from: conversation.updateAt)

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
