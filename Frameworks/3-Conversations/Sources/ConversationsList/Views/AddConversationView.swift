//
//  AddConversationView.swift
//
//
//  Created by Paul VAYSSIER on 17/04/2024.
//

import SwiftUI
import PhotosUI
import Combine

struct AddConversationView<ViewModel: AddConversationViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    PhotosPicker(selection: $viewModel.selectedPhoto,
                                 matching: .images) {
                        if let conversationPicture = viewModel.conversationPicture {
                            Image(uiImage: conversationPicture)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 152, height: 152)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .padding()
                                .foregroundStyle(.white)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                        }
                    }
                                 .padding(.top)
                }
                Form {
                    TextField("Conversation name (Optionnal)", text: $viewModel.conversationName)
                }
                .frame(height: 80)
                .scrollDisabled(true)
                List {
                    Section(header: Text("Group members")) {
                        ForEach(viewModel.conversationMembers.indices, id: \.self) { index in
                            HStack {
                                TextField("Member \(index + 1)", text: $viewModel.conversationMembers[index])
                                    .keyboardType(.phonePad)
                                if index > 0 {
                                    Button(action: {
                                        viewModel.conversationMembers.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                    .foregroundStyle(.blue)
                                }
                            }
                        }
                        Button(action: {
                            viewModel.conversationMembers.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add member")
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.selectedPhoto) { _ in
                    Task {
                        if let loaded = try? await viewModel.selectedPhoto?.loadTransferable(type: Data.self) {
                            debugPrint("Loaded")
                            if let image = UIImage(data: loaded) {
                                viewModel.conversationPicture = image
                            }
                        } else {
                            debugPrint("Failed")
                        }
                    }
                }
            }
            .navigationTitle("Add a conversation")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.didClickCreate()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = AddConversationViewModel()
    return AddConversationView(viewModel: viewModel)
}
