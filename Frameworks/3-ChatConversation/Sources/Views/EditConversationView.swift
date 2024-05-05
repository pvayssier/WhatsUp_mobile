//
//  EditConversationView.swift
//
//
//  Created by Paul VAYSSIER on 30/04/2024.
//

import SwiftUI
import PhotosUI

struct EditConversationView<ViewModel: EditConversationViewModelProtocol>: View {
    init(viewModel: ViewModel, didTapLeaveConversation: @escaping () -> Void) {
        self.viewModel = viewModel
        self.didTapLeaveConversation = didTapLeaveConversation
    }
    

    @ObservedObject var viewModel: ViewModel
    @State var showDeleteAlert = false
    @State var showLeaveAlert = false

    @Environment(\.dismiss) var dismiss
    let didTapLeaveConversation: () -> Void

    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack {
                    ZStack {
                        PhotosPicker(selection: $viewModel.selectedPickerPicture,
                                     matching: .images) {
                            ZStack {
                                if let conversationPicture = viewModel.selectedPicture {
                                    Image(uiImage: conversationPicture)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 152, height: 152)
                                        .clipShape(Circle())
                                } else if let conversationPicture = viewModel.conversationPicture {
                                    conversationPicture
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
                                VStack {
                                    Spacer()
                                    Text("Change picture")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .padding(4)
                                        .background(.gray.opacity(0.5))
                                        .clipShape(Capsule())
                                    Spacer()
                                }
                                .padding(8)
                                .frame(width: 152, height: 152)
                                .background(.ultraThinMaterial.opacity(0.7))
                                .clipShape(Circle())
                            }
                        }
                                     .padding(.top)
                    }
                    Form {
                        Section("Conversation name") {
                            TextField("Conversation name", text: $viewModel.conversationName)
                        }
                    }
                    .frame(height: 80)
                    .scrollDisabled(true)
                    List {
                        Section(header: Text("Group members")) {
                            ForEach(viewModel.conversationUserNames.indices, id: \.self) { index in
                                HStack {
                                    Text(viewModel.conversationUserNames[index])
                                    Spacer()
                                    if viewModel.isAdmin {
                                        Button(action: {
                                            viewModel.conversationUserNames.remove(at: index)
                                            viewModel.conversationUserPhoneNumbers.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                        }
                                        .foregroundStyle(.blue)
                                    }
                                }
                            }
                            ForEach(viewModel.newUserPhoneNumbers.indices, id: \.self) { index in
                                HStack {
                                    if !viewModel.newUserPhoneNumbers.isEmpty {
                                        TextField("Member \(viewModel.conversationUserNames.count + index + 1)", text: $viewModel.newUserPhoneNumbers[index])
                                            .keyboardType(.phonePad)
                                        Button(action: {
                                            viewModel.newUserPhoneNumbers.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                        }
                                        .foregroundStyle(.blue)
                                    }

                                }
                            }
                            Button(action: {
                                viewModel.newUserPhoneNumbers.append("")
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add new member phone")
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        Section {
                            Button {
                                showLeaveAlert = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Leave conversation")
                                        .foregroundStyle(.red)
                                    Spacer()
                                }
                            }
                        }
                        .alert("Are you sure ?", isPresented: $showLeaveAlert) {
                            Button("Cancel", role: .cancel) {
                                showLeaveAlert = false
                            }
                            Button("Leave", role: .destructive) {
                                Task {
                                    let isSucceded = await viewModel.didTapLeave()
                                    if isSucceded {
                                        dismiss()
                                        didTapLeaveConversation()
                                    }
                                }
                            }
                        } message: {
                            Text("You will no longer be able to access \"\(viewModel.conversationName)\" conversation.")
                        }
                        if viewModel.isAdmin {
                            Section {
                                Button {
                                    Task {
                                        showDeleteAlert = true
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Delete conversation")
                                            .foregroundStyle(.red)
                                        Spacer()
                                    }
                                }
                            }
                            .alert("Are you sure ?", isPresented: $showDeleteAlert) {
                                Button("Cancel", role: .cancel) {
                                    showDeleteAlert = false
                                }
                                Button("Delete", role: .destructive) {
                                    Task {
                                        let isSucceded = await viewModel.didTapDelete()
                                        if isSucceded {
                                            dismiss()
                                            didTapLeaveConversation()
                                        }
                                    }
                                }
                            } message: {
                                Text("You will loose all messages in \"\(viewModel.conversationName)\" conversation.")
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.selectedPickerPicture) { _ in
                        Task {
                            if let loaded = try? await viewModel.selectedPickerPicture?.loadTransferable(type: Data.self) {
                                debugPrint("Loaded")
                                if let image = UIImage(data: loaded) {
                                    viewModel.selectedPicture = image
                                }
                            } else {
                                debugPrint("Failed")
                            }
                        }
                    }
                    .toolbar {
                        if viewModel.isModified {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    dismiss()
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    viewModel.didTapSave()
                                }
                            }
                        } else {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

