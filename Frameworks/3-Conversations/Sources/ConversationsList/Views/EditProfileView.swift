//
//  EditProfileView.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import SwiftUI
import PhotosUI

public struct EditProfileView<ViewModel: EditProfileViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel
    @State private var showDeleteAccountAlert: Bool = false
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
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
                                } else if let conversationPicture = viewModel.profilePicture {
                                    conversationPicture
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
                        Section("Username") {
                            TextField("Username", text: $viewModel.username)
                        }
                        Section("Email") {
                            TextField("Email", text: $viewModel.email)
                        }
                        Section("Phone") {
                            TextField("Phone", text: $viewModel.phone)
                        }

                        Section {
                            HStack {
                                VStack {
                                    Button(role: .destructive) {
                                        viewModel.didTapLogout()
                                    } label: {
                                        Text("Logout")
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))
                                    }
                                }

                                Spacer()

                                VStack {
                                    Button(role: .destructive) {
                                        showDeleteAccountAlert = true
                                    } label: {
                                        Text("Delete your account")
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))
                                    }
                                }
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
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
                    }
                    .navigationTitle("Modify your profile")
                    .background(Color(.systemGroupedBackground))
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
                    .alert(isPresented: $showDeleteAccountAlert) {
                        Alert(title: Text("Delete your account"),
                              message: Text("""
Are you sure you want to delete your account?
This action is irreversible.
"""),
                              primaryButton: .destructive(Text("Delete"), action: {
                                viewModel.didTapDelete()
                              }),
                              secondaryButton: .cancel())
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}
