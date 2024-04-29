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

                                DaySeparator(messageDate: message.createdAt,
                                             prevMessageDate: previousMessage(index: viewModel.chatConversation.messages.firstIndex(of: message))?.createdAt)
                            MessageView(senderName: viewModel.chatConversation.users.first(where: { $0.id == message.senderId })?.username ?? "",
                                        message: message,
                                        picture: viewModel.usersPicture[message.senderId].flatMap { $0 },
                                        isMyMessage: message.senderId == viewModel.myUser.id,
                                        position: .calculatePositionInGroup(previousMessage: previousMessage(index: viewModel.chatConversation.messages.firstIndex(of: message)),
                                                                            message: message,
                                                                            nextMessage: nextMessage(index: viewModel.chatConversation.messages.firstIndex(of: message))))
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
                MessageInputView(text: $viewModel.pendingMessage, action: {
                    viewModel.didClickSend()
                })
                .background(Color(uiColor: UIColor.systemBackground))
            }
            .frame(minWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height - 100)
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
                ChatToolbarContent(groupPicture: viewModel.groupPicture, groupName: viewModel.chatConversation.name)
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

struct DaySeparator: View {

    init(messageDate: Date, prevMessageDate: Date?) {
        if let prevMessageDate, Calendar.current.isDate(messageDate, inSameDayAs: prevMessageDate) {
            self.showDate = false
        } else {
            self.showDate = true
        }

        if Calendar.current.isDate(messageDate, inSameDayAs: Date()) {
            self.formatDate = "Aujourd'hui"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Calendar.current.locale
            formatter.dateFormat = "EEEE d MMMM" + (Calendar.current.isDate(messageDate,
                                                                            equalTo: Date(),
                                                                            toGranularity: .year) ? "" : " yyyy")
            self.formatDate = formatter.string(from: messageDate)
        }
    }

    private let showDate: Bool
    private let formatDate: String

    var body: some View {
        if showDate {
            VStack {
                Text(formatDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(10)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(20)
        }
    }
}
