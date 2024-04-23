//
//  ChatConversationViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 23/04/2024.
//

import SwiftUI
import Factory
import SocketIO
import Models
import UITools

public protocol ChatConversationViewModelProtocol: ObservableObject {
    var pendingMessage: String { get set }
    var chatConversation: ChatConversation { get }
    var myUser: User { get }
    var onDisappear: () -> Void { get }
    var groupPicture: Image? { get }
    func viewDidAppear()
    func didClickSend()
}

final public class ChatConversationViewModel: ChatConversationViewModelProtocol {

    @Injected(\.chatConversationService) private var chatConversationService
    @Published public var chatConversation: ChatConversation = ChatConversation(id: "",
                                                                                name: "",
                                                                                messages: [],
                                                                                users: [],
                                                                                pictureURL: nil)
    @Published public var groupPicture: Image?

    public let onDisappear: () -> Void
    public var pendingMessage: String = ""
    public var myUser: User

    private let socketManager: SocketManager
    private let socketClient: SocketIOClient
    private var conversationId: String


    public init(conversationId: String, didClickBack: @escaping () -> Void) {
        let userDefault = Container.shared.userDefaults()

        self.conversationId = conversationId
        self.myUser = userDefault.user ?? User(id: "", username: "", email: "", phone: "")

        self.socketManager = SocketManager(socketURL: URL(string: userDefault.baseURL ?? "http://localhost:3000")!)
        self.socketClient = socketManager.defaultSocket
        self.onDisappear = didClickBack
    }

    @MainActor
    public func viewDidAppear() {
        Task {
            do {
                chatConversation = try await chatConversationService.fetchMessages(conversationId: conversationId)
                setupPicture(with: chatConversation.pictureURL)
            } catch {
                debugPrint(error)
            }
        }
        connectSocket()
    }

    @MainActor
    public func didClickSend() {
        guard !pendingMessage.isEmpty else { return }

        let message = SendMessageDTO(content: pendingMessage,
                                     senderId: myUser.id,
                                     conversationId: conversationId)

        if let messageData = try? JSONEncoder().encode(message),
           let messageString = String(data: messageData, encoding: .utf8) {
            socketClient.emit("send_message", messageString)
        }

        pendingMessage = ""
    }

    private func connectSocket() {
        let conversationId = conversationId

        socketClient.connect()
        socketClient.once(clientEvent: .connect) { [weak self] data, ack in
            self?.socketClient.emit("joinConversation", conversationId)
        }
        socketClient.on("new_message") { [weak self] data, ack in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // Utilisez cela si vos dates sont en format ISO 8601
            if let data = (data[0] as? String)?.data(using: .utf8),
               let messageDTO = try? decoder.decode(MessageDTO.self, from: data),
               let self {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.locale = Calendar.current.locale
                dateFormatter.timeZone = Calendar.current.timeZone

                let createdAt = dateFormatter.date(from: messageDTO.createdAt) ?? Date()

                let message = Message(id: messageDTO.id,
                                      content: messageDTO.content,
                                      senderId: messageDTO.senderId,
                                      createdAt: createdAt)

                chatConversation.messages.append(message)
            }
        }
    }

    @MainActor
    private func setupPicture(with url: URL?) {
        guard let url else { return }
        Task {
            self.groupPicture = await Image.loadAsync(from: url, defaultImage: Image(systemName: "person.2.fill"))
        }
    }
}
