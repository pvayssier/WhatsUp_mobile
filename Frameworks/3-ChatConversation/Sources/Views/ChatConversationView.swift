//
//  ChatConversationView.swift
//
//
//  Created by Paul VAYSSIER on 22/04/2024.
//

import SwiftUI
import Models

public struct ChatConversationView<ViewModel: ChatConversationViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Spacer()
                        .frame(height: 10)
                    ScrollViewReader { proxy in
                        ForEach(viewModel.chatConversation.messages, id: \.id) { message in
                            MessageView(message: message,
                                        isMyMessage: message.senderId == viewModel.myUser.id,
                                        isGroup: viewModel.chatConversation.messages.first { nextMessage in
                                nextMessage.createdAt > message.createdAt
                            }?.senderId == message.senderId)
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let url: NSURL = URL(string: "TEL://")! as NSURL
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } label: {
                    Image(systemName: "phone.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                }

            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

struct MessageView: View {
    var message: Message
    var isMyMessage: Bool
    var isGroup: Bool = false

    var body: some View {
        HStack {
            if isMyMessage {
                Spacer(minLength: 30)
                Text(message.content)
                    .padding(10)
                    .background(Color("sendedMessageColor", bundle: .main))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 10)
                    .padding(.bottom, isGroup ? 2 : 6)
            } else {
                Text(message.content)
                    .padding(10)
                    .background(Color("receivedMessageColor", bundle: .main))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 10)
                    .padding(.bottom, isGroup ? 1 : 6)
                Spacer(minLength: 30)
            }
        }
    }
}

struct MessageInputView: View {
    @Binding var text: String
    var action: () -> Void

    var body: some View {
        HStack {
            TextField("", text: $text)
                .padding(6)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(.systemGray5), lineWidth: 1))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            Button(action: {
                action()
            }, label: {
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(uiColor: UIColor.tintColor))
                    .background(Color(uiColor: .systemBackground))
                    .padding(.trailing, 10)
                    .rotationEffect(.degrees(45))
                    .padding(.vertical, 6)
            })
        }
        .padding(0)
    }
}

struct ChatToolbarContent: View {
    var groupPicture: Image?
    var groupName: String

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if let groupPicture = groupPicture {
                    groupPicture
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(10)
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.white)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 0.5) {
                    Text(groupName)
                        .font(.headline)
                    Text("tap here for conversation info")
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                }

            }
        }

    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
