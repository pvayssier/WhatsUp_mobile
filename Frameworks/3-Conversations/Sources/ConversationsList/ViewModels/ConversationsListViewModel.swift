//
//  ConversationsListViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import Foundation
import Factory
import Models

public protocol ConversationsListViewModelProtocol: ObservableObject {
    func viewDidAppear() async
    func didForceRefresh() async
    var conversations: [Conversation] { get }
}

final public class ConversationsListViewModel: ConversationsListViewModelProtocol {

    @Injected(\.conversationsListService) private var conversationsListService

    @Published public private(set) var conversations: [Conversation] = []

    public init() { }

    @MainActor
    public func viewDidAppear() {
        Task {
            conversations = await conversationsListService.fetchConversations()
        }
    }

    @MainActor
    public func didForceRefresh() {
        Task {
            conversations = await conversationsListService.fetchConversations()
        }
    }
}

