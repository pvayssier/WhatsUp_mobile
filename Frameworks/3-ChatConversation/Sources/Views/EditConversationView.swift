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
                                    Text(String(localized: "EditConversation.changePicture"))
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
                        Section(String(localized: "EditConversation.conversationName")) {
                            TextField(String(localized: "EditConversation.conversationName"), text: $viewModel.conversationName)
                        }
                    }
                    .frame(height: 80)
                    .scrollDisabled(true)
                    List {
                        Section(header: Text(String(localized: "EditConversation.groupMembers"))) {
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
                                        TextField("\(String(localized: "EditConversation.member")) \(viewModel.conversationUserNames.count + index + 1)", text: $viewModel.newUserPhoneNumbers[index])
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
                                    Text(String(localized: "EditConversation.addNewMember"))
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
                                    Text(String(localized: "EditConversation.leaveConversation"))
                                        .foregroundStyle(.red)
                                    Spacer()
                                }
                            }
                        }
                        .alert(String(localized: "EditConversation.LeaveConversation.AreYouSure.title"), isPresented: $showLeaveAlert) {
                            Button(String(localized: "EditConversation.LeaveConversation.AreYouSure.cancel"), role: .cancel) {
                                showLeaveAlert = false
                            }
                            Button(String(localized: "EditConversation.LeaveConversation.AreYouSure.leave"), role: .destructive) {
                                Task {
                                    let isSucceded = await viewModel.didTapLeave()
                                    if isSucceded {
                                        dismiss()
                                        didTapLeaveConversation()
                                    }
                                }
                            }
                        } message: {
                            Text("\(String(localized: "EditConversation.LeaveConversation.AreYouSure.Message.prefix")) \"\(viewModel.conversationName)\"\(String(localized: "EditConversation.LeaveConversation.AreYouSure.Message.sufix"))")
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
                                        Text(String(localized: "EditConversation.DeleteConversation.button"))
                                            .foregroundStyle(.red)
                                        Spacer()
                                    }
                                }
                            }
                            .alert(String(localized: "EditConversation.DeleteConversation.AreYouSure.title"), isPresented: $showDeleteAlert) {
                                Button(String(localized: "EditConversation.DeleteConversation.AreYouSure.cancel"), role: .cancel) {
                                    showDeleteAlert = false
                                }
                                Button(String(localized: "EditConversation.DeleteConversation.AreYouSure.delete"), role: .destructive) {
                                    Task {
                                        let isSucceded = await viewModel.didTapDelete()
                                        if isSucceded {
                                            dismiss()
                                            didTapLeaveConversation()
                                        }
                                    }
                                }
                            } message: {
                                Text("\(String(localized: "EditConversation.DeleteConversation.AreYouSure.Message.prefix")) \"\(viewModel.conversationName)\"\(String(localized: "EditConversation.DeleteConversation.AreYouSure.Message.sufix"))")
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
                                Button(String(localized: "EditConversation.cancel")) {
                                    dismiss()
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "EditConversation.save")) {
                                    viewModel.didTapSave()
                                }
                            }
                        } else {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "EditConversation.done")) {
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

