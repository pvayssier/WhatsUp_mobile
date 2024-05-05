//
//  EditGroupViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 30/04/2024.
//

import SwiftUI
import PhotosUI
import Combine
import Factory
import Models

protocol EditConversationViewModelProtocol: ObservableObject {
    var conversationName: String { get set }
    var conversationPicture: Image? { get set }
    var selectedPickerPicture: PhotosPickerItem? { get set }
    var selectedPicture: UIImage? { get set }
    var conversationUserNames: [String] { get set }
    var conversationUserPhoneNumbers: [String] { get set }
    var newUserPhoneNumbers: [String] { get set }
    var isLoading: Bool { get }
    var isModified: Bool { get }
    var showAlert: Bool { get set }
    var isAdmin: Bool { get }
    var myUser: User { get }
    func didTapLeave() async -> Bool
    func didTapDelete() async -> Bool
    func didTapSave()
}

final class EditConversationViewModel: EditConversationViewModelProtocol {

    @Injected(\.editConversationService) private var editConversationService

    @Published var conversationName: String = ""
    @Published var conversationUserNames: [String] = []
    @Published var conversationUserPhoneNumbers: [String] = []
    @Published var newUserPhoneNumbers: [String] = []
    @Published var conversationPicture: Image?
    @Published var selectedPickerPicture: PhotosPickerItem?
    @Published var selectedPicture: UIImage?
    @Published var isLoading: Bool = false
    @Published var isModified: Bool = false
    @Published var showAlert: Bool = false

    let myUser: User
    let isAdmin: Bool
    private let conversationId: String

    private var cancellables = Set<AnyCancellable>()

    init (conversation: ChatConversation, image: Image?) {
        self.conversationName = conversation.name
        self.conversationPicture = image
        self.myUser = Container.shared.userDefaults().user ?? User(id: "", username: "", email: "", phone: "")

        conversationId = conversation.id

        isAdmin = conversation.ownedBy == myUser.id

        let conversationUserNames: [String] = conversation.users.compactMap { user in
            if user.id == myUser.id {
                return nil
            } else if user.id == conversation.ownedBy {
                return " \(user.username) 👑 (Admin)"
            } else {
                return user.username
            }
        }
        self.conversationUserPhoneNumbers = conversation.users.compactMap { user in
            if user.id == myUser.id {
                return nil
            } else {
                return user.phone
            }
        }

        self.conversationUserNames = conversationUserNames

        Publishers.CombineLatest4($conversationName,
                                  $conversationUserNames,
                                  $newUserPhoneNumbers,
                                  $selectedPicture)
        .map { name, users, newUsers, picture in
            if name != conversation.name
                || users != conversationUserNames
                || !newUsers.isEmpty
                || picture != nil {
                return true
            }
            return false
        }
        .assign(to: \.isModified, on: self)
        .store(in: &cancellables)
    }

    @MainActor
    func didTapLeave() async -> Bool {
        return await editConversationService.leaveConversation(conversationId: conversationId)
    }

    @MainActor
    func didTapDelete() async -> Bool {
        showAlert = true
        return await editConversationService.deleteConversation(conversationId: conversationId)
    }

    @MainActor
    func didTapSave() {
        isLoading = true
        Task {
            var users = conversationUserPhoneNumbers
            users.append(contentsOf: newUserPhoneNumbers)
            users.insert(myUser.phone, at: 0)
            do {
                let chatConversation = try await editConversationService.updateConversation(name: conversationName,
                                                                                            users: users,
                                                                                            pictureData: selectedPicture?.jpegData(compressionQuality: 1),
                                                                                            conversationId: conversationId)
                conversationName = chatConversation.name
                if let pictureUrl = chatConversation.pictureURL {
                    conversationPicture = await Image.loadAsync(from: pictureUrl)
                }
                conversationUserNames = chatConversation.users.compactMap { user in
                    if user.id == myUser.id {
                        return nil
                    } else {
                        return user.username
                    }
                }
                conversationUserPhoneNumbers = chatConversation.users.compactMap { user in
                    if user.id == myUser.id {
                        return nil
                    } else {
                        return user.phone
                    }
                }
                newUserPhoneNumbers = []
                selectedPicture = nil
                selectedPickerPicture = nil
                isLoading = false
                isModified = false
            } catch {
                isLoading = false
                debugPrint("Error while updating conversation: \(error)")
            }
        }
    }
}
