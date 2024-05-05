//
//  ChatConversationView.swift
//
//
//  Created by Paul VAYSSIER on 22/04/2024.
//

import SwiftUI
import UIKit
import Models

public struct ChatConversationView<ViewModel: ChatConversationViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private func previousMessage(index: Int?) -> Message? {
        if let index, index > 0 {
            return viewModel.chatConversation.messages[index - 1]
        }
        return nil
    }

    private func nextMessage(index: Int?) -> Message? {
        if let index, index < viewModel.chatConversation.messages.count - 1 {
            return viewModel.chatConversation.messages[index + 1]
        }
        return nil
    }

    public var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    if viewModel.chatConversation.messages.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 10)
                    ScrollViewReader { proxy in
                        ForEach(viewModel.chatConversation.messages, id: \.id) { message in

                            DaySeparatorView(messageDate: message.createdAt,
                                             prevMessageDate: previousMessage(index: viewModel.chatConversation.messages.firstIndex(of: message))?.createdAt)
                            MessageView(senderName: viewModel.chatConversation.users.first(where: { $0.id == message.senderId })?.username ?? "undefined user",
                                        message: message,
                                        picture: viewModel.usersPicture[message.senderId].flatMap { $0 },
                                        isMyMessage: message.senderId == viewModel.myUser.id,
                                        position: .calculatePositionInGroup(previousMessage: previousMessage(index: viewModel.chatConversation.messages.firstIndex(of: message)),
                                                                            message: message,
                                                                            nextMessage: nextMessage(index: viewModel.chatConversation.messages.firstIndex(of: message))),
                                        reportAction: viewModel.reportMessage)
                        }
                        .onChange(of: viewModel.chatConversation.messages.count) { _ in
                            if let lastMessageId = viewModel.chatConversation.messages.last?.id {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                        .onAppear {
                            if let lastMessageId = viewModel.chatConversation.messages.last?.id {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .background {
                    Image("backgroundImage", bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                MessageInputView(viewModel.didClickSend)
            }
            .frame(minWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(Color("backgroundColor", bundle: .main))
            .onAppear {
                viewModel.viewDidAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ChatToolbarContent(groupPicture: viewModel.groupPicture, 
                                   groupName: viewModel.chatConversation.name,
                                   conversation: viewModel.chatConversation,
                                   dismissAction: { dismiss() },
                                   reloadAction: { viewModel.viewDidAppear() })
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

