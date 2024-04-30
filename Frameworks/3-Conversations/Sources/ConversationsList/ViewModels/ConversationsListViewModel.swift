//
//  ConversationsListViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Factory
import SocketIO
import Models
import Tools

public protocol ConversationsListViewModelProtocol: ObservableObject {
    func viewDidAppear() async
    func didForceRefresh() async
    var conversations: [Conversation] { get }
}

final public class ConversationsListViewModel: ConversationsListViewModelProtocol {

    @Published public private(set) var conversations: [Conversation] = []

    @Injected(\.conversationsListService) private var conversationsListService
    private var userDefaults: UserDefaultsManagerProtocol
    private let userNotLogged: () -> Void

    // WebSocket
    private var socketManager: SocketManager
    private var socketClient: SocketIOClient

    public init(userNotLogged: @escaping () -> Void) {
        self.userNotLogged = userNotLogged
        self.userDefaults = Container.shared.userDefaultsManager()
        socketManager = SocketManager(socketURL: URL(string: userDefaults.baseURL ?? "http://localhost:3000")!)
        socketClient = socketManager.defaultSocket
    }

    @MainActor
    public func viewDidAppear() {
        Task {
            do {
                conversations = try await conversationsListService.fetchConversations()
                    .sorted(by: { lhs, rhs in
                        lhs.updateAt > rhs.updateAt
                    })
            } catch {
                if let error = error as? NetworkError, error == NetworkError.unauthorized {
                    userNotLogged()
                }
            }
        }
        if let user = userDefaults.user {
            subscribeNotification(userId: user.id)
        }
    }

    @MainActor
    public func didForceRefresh() {
        Task {
            do {
                conversations = try await conversationsListService.fetchConversations()
                    .sorted(by: { lhs, rhs in
                        lhs.updateAt > rhs.updateAt
                    })
            } catch {
                if let error = error as? NetworkError, error == NetworkError.unauthorized {
                    userNotLogged()
                }
            }
        }
    }

    @MainActor
    private func subscribeNotification(userId: String) {
        socketClient.connect()

        socketClient.once(clientEvent: .connect) { [weak self] data, ack in
            self?.socketClient.emit("joinNotification", userId)
            print( "socket.io connected", userId)
        }

        socketClient.on("new_message") { [weak self] data, ack in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601  // Utilisez cela si vos dates sont en format ISO 8601
            if let data = (data[0] as? String)?.data(using: .utf8),
               let conversationDTO = try? decoder.decode(ConversationDTO.self, from: data),
               let self {
                conversations = conversations.map({ conversation -> Conversation in
                    if conversation.id == conversationDTO.id{
                        let users = conversationDTO.users.map {
                            User(id: $0.id,
                                 username: $0.pseudo,
                                 email: $0.email,
                                 phone: $0.phone)
                        }

                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        formatter.locale = Calendar.current.locale
                        formatter.timeZone = Calendar.current.timeZone

                        var lastMessage: Message? = nil
                        if let message = conversationDTO.lastMessage,
                           let dateFormat = formatter.date(from: message.createdAt) {
                            lastMessage = Message(id: message.id,
                                                  content: message.content,
                                                  senderId: message.senderId,
                                                  createdAt: dateFormat)
                        }

                        let createdAtDate = formatter.date(from: conversationDTO.createAt) ?? Date()
                        let updatedAtDate = formatter.date(from: conversationDTO.updateAt) ?? Date()

                        return Conversation(id: conversationDTO.id,
                                            name: conversationDTO.name,
                                            users: users,
                                            lastMessage: lastMessage,
                                            createdAt: createdAtDate,
                                            updateAt: updatedAtDate,
                                            pictureURL: conversationDTO.pictureURL)
                    }
                    return conversation
                }).sorted(by: { lhs, rhs in
                    lhs.updateAt > rhs.updateAt
                })
            }
        }
    }
}

