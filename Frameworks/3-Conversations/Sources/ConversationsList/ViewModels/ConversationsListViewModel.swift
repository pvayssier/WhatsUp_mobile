//
//  ConversationsListViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Factory
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
    private let userNotLogged: () -> Void

    public init(userNotLogged: @escaping () -> Void) {
        self.userNotLogged = userNotLogged
    }

    @MainActor
    public func viewDidAppear() {
        Task {
            do {
                conversations = try await conversationsListService.fetchConversations()
            } catch {
                if let error = error as? NetworkError, error == NetworkError.unauthorized {
                    userNotLogged()
                }
            }
        }
    }

    @MainActor
    public func didForceRefresh() {
        Task {
            do {
                conversations = try await conversationsListService.fetchConversations()
            } catch {
                if let error = error as? NetworkError, error == NetworkError.unauthorized {
                    userNotLogged()
                }
            }
        }
    }
}

