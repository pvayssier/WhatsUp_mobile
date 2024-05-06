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
                        ZStack {
                            if let conversationPicture = viewModel.conversationPicture {
                                Image(uiImage: conversationPicture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 152, height: 152)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                    .frame(width: 120, height: 120)
                                    .padding()
                                    .foregroundStyle(.white)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())
                            }
                            VStack {
                                Spacer()
                                Text(String(localized: "EditProfile.changePicture"))
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
                Text(viewModel.errorText ?? "error")
                    .foregroundColor(viewModel.errorText != nil ? .red : .clear)
                Form {
                    TextField(String(localized: "AddConversation.conversationName"), text: $viewModel.conversationName)
                }
                .frame(height: 80)
                .scrollDisabled(true)
                List {
                    Section(header: Text(String(localized: "AddConversation.groupMembers"))) {
                        ForEach(viewModel.conversationMembers.indices, id: \.self) { index in
                            HStack {
                                TextField("Member \(index + 1)", text: $viewModel.conversationMembers[index])
                                    .keyboardType(.phonePad)
                                    .foregroundColor(viewModel.conversationMembersValidate[index] ? .primary : .red)
                                    .onChange(of: viewModel.conversationMembers[index]) { newValue in
                                        if newValue.count > 10 {
                                            viewModel.conversationMembers[index] = String(viewModel.conversationMembers[index].prefix(10))
                                        }
                                    }
                                if index > 0 {
                                    Button {
                                        hideKeyboard()
                                        viewModel.conversationMembers.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                    }
                                    .foregroundStyle(.blue)
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        Button(action: {
                            viewModel.conversationMembers.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(String(localized: "AddConversation.addMember"))
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
            .navigationTitle(String(localized: "AddConversation.title"))
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "AddConversation.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "AddConversation.create")) {
                        if viewModel.didClickCreate() {
                            dismiss()
                        }
                    }
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

#Preview {
    let viewModel = AddConversationViewModel()
    return AddConversationView(viewModel: viewModel)
}
