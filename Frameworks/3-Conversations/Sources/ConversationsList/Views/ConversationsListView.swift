//
//  ConversationsListView.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI
import Models
import UITools
import ChatConversation

public struct ConversationsListView<ViewModel: ConversationsListViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    @State private var presentAddConversationView: Bool = false
    @State private var presentEditProfileView: Bool = false

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink(destination:
                                    ChatConversationView(viewModel: ChatConversationViewModel(conversationId: conversation.id,
                                                                                              didClickBack: viewModel.didQuitSubview))
                                        .onAppear {
                                            viewModel.didSelectConversation()
                                        }
                    ) {
                        VStack {
                            SingleConversationView(viewModel: SingleConversationViewState(conversation: conversation))
                            if conversation != viewModel.conversations.last {
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Conversations")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentAddConversationView.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            presentEditProfileView = true
                        } label: {
                            Group {
                                if let picture = viewModel.userPicture {
                                    picture
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle")
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.didForceRefresh()
                }
            }
            .sheet(isPresented: $presentAddConversationView) {
                Task {
                    await viewModel.didForceRefresh()
                }
            } content: {
                let viewModel = AddConversationViewModel()
                AddConversationView(viewModel: viewModel)
            }
            .sheet(isPresented: $presentEditProfileView) {
                let viewModel = EditProfileViewModel(picture: viewModel.userPicture, viewModel.userNotLogged)
                EditProfileView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                await viewModel.viewDidAppear()
            }
        }
    }

}

#if DEBUG
struct ConversationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsListView(viewModel: ConversationsListViewModel(userNotLogged: {}))
    }
}
#endif
