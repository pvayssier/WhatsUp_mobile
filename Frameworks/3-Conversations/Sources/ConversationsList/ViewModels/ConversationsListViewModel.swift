//
//  ConversationsListViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI
import Factory
import SocketIO
import Models
import Tools

public protocol ConversationsListViewModelProtocol: ObservableObject {
    func viewDidAppear() async
    func didForceRefresh() async
    func didSelectConversation()
    func didQuitSubview()
    var conversations: [Conversation] { get }
    var myUser: User { get }
    var userPicture: Image? { get }
    var singleConversationStates: [String: any SingleConversationViewStateProtocol] { get }
    var userNotLogged: () -> Void { get }
    var isLoading: Bool { get }
}

final public class ConversationsListViewModel: ConversationsListViewModelProtocol {

    @Published public private(set) var conversations: [Conversation] = []
    @Published public var userPicture: Image?
    @Published public var singleConversationStates: [String: any SingleConversationViewStateProtocol] = [:]
    @Published public var isLoading: Bool = false
    public let myUser: User
    public let userNotLogged: () -> Void

    @Injected(\.conversationsListService) private var conversationsListService
    private var userDefaults: UserDefaultsManagerProtocol

    // WebSocket
    private var socketManager: SocketManager
    private var socketClient: SocketIOClient

    public init(userNotLogged: @escaping () -> Void) {
        self.userNotLogged = userNotLogged
        self.userDefaults = Container.shared.userDefaultsManager()
        socketManager = SocketManager(socketURL: URL(string: userDefaults.baseURL ?? "http://172.16.70.196:3000/")!)
        socketClient = socketManager.defaultSocket
        myUser = userDefaults.user ?? User(id: "", username: "", email: "", phone: "")

        if let url = myUser.pictureUrl {
            Task {
                userPicture = await Image.loadAsync(from: url)
            }
        } else {
            userPicture = nil
        }
        Task {
            await setupSingleConversationViewModels()
        }
    }

    @MainActor
    public func viewDidAppear() {
        setupSingleConversationViewModels()
        fetchConversations()
    }

    @MainActor
    public func didForceRefresh() {
        setupSingleConversationViewModels()
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
    public func setupSingleConversationViewModels() {
        let viewModels = conversations.map { conversation in
            SingleConversationViewState(conversation: conversation)
        }
        viewModels.forEach { viewModel in
            singleConversationStates[viewModel.id] = viewModel
        }
    }

    public func didSelectConversation() {
        socketClient.disconnect()
    }

    public func didQuitSubview() {
        Task {
            await viewDidAppear()
        }
    }

    @MainActor
    private func fetchConversations() {
        isLoading = true
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
            isLoading = false
        }
        if let user = userDefaults.user {
            subscribeNotification(userId: user.id)
        }
    }

    @MainActor
    private func subscribeNotification(userId: String) {
        socketClient.connect()

        socketClient.once(clientEvent: .connect) { [weak self] data, ack in
            self?.socketClient.emit("joinNotification", userId)
            debugPrint( "socket.io connected", userId)
        }

        socketClient.on("new_message") { [weak self] data, ack in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let data = (data[0] as? String)?.data(using: .utf8),
               let conversationDTO = try? decoder.decode(ConversationDTO.self, from: data),
               let self {
                if conversations.first(where: { $0.id == conversationDTO.id }) == nil {
                    conversations.append(self.dataToConversation(conversationDTO: conversationDTO))
                    conversations = conversations.sorted(by: { lhs, rhs in
                        lhs.updateAt > rhs.updateAt
                    })
                } else {
                    conversations = conversations.compactMap({ [weak self] conversation -> Conversation? in
                        if conversation.id == conversationDTO.id {
                            return self?.dataToConversation(conversationDTO: conversationDTO)
                        }
                        return conversation
                    }).sorted(by: { lhs, rhs in
                        lhs.updateAt > rhs.updateAt
                    })
                }
            }
        }
    }

    private func dataToConversation(conversationDTO: ConversationDTO) -> Conversation {
                let users = conversationDTO.users.map {
                    if let pictureUrl = $0.pictureUrl {
                        return User(id: $0.id,
                                    username: $0.pseudo,
                                    email: $0.email,
                                    phone: $0.phone,
                                    pictureUrl: URL(string: pictureUrl))
                    }
                    return User(id: $0.id,
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

}

