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
    var chatConversation: ChatConversation { get }
    var myUser: User { get }
    var onDisappear: () -> Void { get }
    var groupPicture: Image? { get }
    var usersPicture: [String: Image?] { get }
    func didClickSend(content: String)
    func reportMessage(messageId: String)
    func viewDidAppear()
}

final public class ChatConversationViewModel: ChatConversationViewModelProtocol {

    @Injected(\.chatConversationService) private var chatConversationService
    @Published public var chatConversation: ChatConversation = ChatConversation(id: "",
                                                                                name: "",
                                                                                messages: [],
                                                                                users: [],
                                                                                ownedBy: "",
                                                                                pictureURL: nil)
    @Published public var groupPicture: Image?
    @Published public var usersPicture: [String: Image?] = [:]

    public var onDisappear: () -> Void = {}
    public var myUser: User

    private let socketManager: SocketManager
    private let socketClient: SocketIOClient
    private var conversationId: String
    private var isSubscribed = false


    public init(conversationId: String, didClickBack: @escaping () -> Void) {
        let userDefault = Container.shared.userDefaults()

        self.conversationId = conversationId
        self.myUser = userDefault.user ?? User(id: "", username: "", email: "", phone: "")

        self.socketManager = SocketManager(socketURL: URL(string: userDefault.baseURL ?? "http://172.16.70.196:3000/")!)
        self.socketClient = socketManager.defaultSocket
        self.onDisappear = { [weak self] in
            didClickBack()
            self?.socketClient.disconnect()
        }
    }

    @MainActor
    public func viewDidAppear() {
        Task {
            do {
                chatConversation = try await chatConversationService.fetchMessages(conversationId: conversationId)
                setupPictures(with: chatConversation.pictureURL)
            } catch {
                debugPrint(error)
            }
        }
        connectSocket()
    }

    @MainActor
    public func didClickSend(content: String) {
        let message = SendMessageDTO(content: content,
                                     senderId: myUser.id,
                                     conversationId: conversationId)

        if let messageData = try? JSONEncoder().encode(message),
           let messageString = String(data: messageData, encoding: .utf8) {
            socketClient.emit("send_message", messageString)
        }
    }

    public func reportMessage(messageId: String) {
        Task {
            await chatConversationService.reportMessage(messageId: messageId)
        }
    }

    private func connectSocket() {
        guard !isSubscribed else { return }
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
    private func setupPictures(with url: URL?) {
        self.chatConversation.users.forEach { user in
            if let pictureURL = user.pictureUrl {
                Task {
                    self.usersPicture[user.id] = await Image.loadAsync(from: pictureURL, defaultImage: Image(systemName: "person.2.fill"))
                }
            }
        }
        Task {
            guard let url else { return }
            self.groupPicture = await Image.loadAsync(from: url, defaultImage: Image(systemName: "person.2.fill"))
        }
    }
}
