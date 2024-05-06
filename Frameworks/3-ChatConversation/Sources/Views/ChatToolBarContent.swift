//
//  ChatToolBarContent.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI
import Models

struct ChatToolbarContent: View {
    var groupPicture: Image?
    var groupName: String
    var dismissAction: () -> Void
    var reloadAction: () -> Void

    private var conversation: ChatConversation

    init(groupPicture: Image? = nil, 
         groupName: String,
         conversation: ChatConversation,
         dismissAction: @escaping () -> Void,
         reloadAction: @escaping () -> Void) {
        self.groupPicture = groupPicture
        self.groupName = groupName
        self.conversation = conversation
        self.dismissAction = dismissAction
        self.reloadAction = reloadAction
    }

    @State private var showEditGroupView = false

    var body: some View {
        Button {
            showEditGroupView = true
        } label: {
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
                        Text(String(localized: "ChatConversation.editConversation"))
                            .font(.footnote)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEditGroupView) {
            reloadAction()
        } content: {
            let viewModel = EditConversationViewModel(conversation: conversation, image: groupPicture)
            EditConversationView(viewModel: viewModel, didTapLeaveConversation: dismissAction)
        }

    }
}
