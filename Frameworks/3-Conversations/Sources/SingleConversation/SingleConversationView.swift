//
//  SingleConversationView.swift
//
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI
import Models
import UITools

public struct SingleConversationView<ViewModel: SingleConversationViewStateProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack {
            if let conversationPicture = viewModel.picture {
                conversationPicture
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(12)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading) {

                    HStack {
                        Text(viewModel.groupName)
                            .font(.headline)
                        Spacer()
                        Text(viewModel.formatDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text(viewModel.formatLastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                VStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(.top, 6)
            .padding(.trailing, 4)
            Spacer()
        }
        .frame(height: 70)
        .padding(.leading, 4)
    }
}

#if DEBUG
#Preview {
    let groupMembers: [User] = [
        .init(id: "1",
              username: "Audran",
              email: "audran@test.fr",
              phone: "0612345678"),
        .init(id: "2",
              username: "Victor",
              email: "victor@test.fr",
              phone: "0623456789"),
    ]
    let message = Message(id: "1",
                          content: "Salut les gars, comment ça va",
                          senderId: "2",
                          createdAt: Date())
    let conversation = Conversation(id: "test",
                                    name: "Group Name",
                                    users: groupMembers,
                                    lastMessage: message,
                                    createdAt: Date().addingTimeInterval(-1000),
                                    updateAt: message.createdAt,
                                    pictureURL: nil)
    let viewModel = SingleConversationViewState(conversation: conversation)
    return SingleConversationView(viewModel: viewModel)
}
#endif
