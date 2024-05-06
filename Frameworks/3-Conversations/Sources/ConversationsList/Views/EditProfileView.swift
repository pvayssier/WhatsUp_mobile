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
                    Form {
                        Section(String(localized: "EditProfile.username")) {
                            TextField(String(localized: "EditProfile.username"), text: $viewModel.username)
                        }
                        Section(String(localized: "EditProfile.email")) {
                            TextField(String(localized: "EditProfile.email"), text: $viewModel.email)
                        }
                        Section(String(localized: "EditProfile.phone")) {
                            TextField(String(localized: "EditProfile.phone"), text: $viewModel.phone)
                        }

                        Section {
                            HStack {
                                VStack {
                                    Button(role: .destructive) {
                                        viewModel.didTapLogout()
                                    } label: {
                                        Text(String(localized: "EditProfile.logout"))
                                            .fontWeight(.bold)
                                            .font(.system(size: 15))
                                    }
                                }

                                Spacer()

                                VStack {
                                    Button(role: .destructive) {
                                        showDeleteAccountAlert = true
                                    } label: {
                                        Text(String(localized: "EditProfile.delete"))
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
                    .navigationTitle(String(localized: "EditProfile.title"))
                    .background(Color(.systemGroupedBackground))
                    .toolbar {
                        if viewModel.isModified {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(String(localized: "EditProfile.cancel")) {
                                    dismiss()
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "EditProfile.save")) {
                                    viewModel.didTapSave()
                                }
                            }
                        } else {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "EditProfile.done")) {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .alert(isPresented: $showDeleteAccountAlert) {
                        Alert(title: Text(String(localized: "EditProfile.DeleteAccount.AreYouSure.title")),
                              message: Text(String(localized: "EditProfile.DeleteAccount.AreYouSure.message")),
                              primaryButton: .destructive(Text(String(localized: "EditProfile.DeleteAccount.AreYouSure.delete")), action: {
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
