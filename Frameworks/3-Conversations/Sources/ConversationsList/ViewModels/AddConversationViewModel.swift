//
//  AddConversationViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 20/04/2024.
//

import SwiftUI
import PhotosUI
import Factory
import Models

protocol AddConversationViewModelProtocol: ObservableObject {
    var conversationName: String { get set }
    var errorText: String? { get }
    var conversationMembers: [String] { get set }
    var selectedPhoto: PhotosPickerItem? { get set }
    var conversationPicture: UIImage? { get set }
    var conversationMembersValidate: [Bool] { get }
    func didClickCreate() -> Bool
}

final class AddConversationViewModel: AddConversationViewModelProtocol, ObservableObject {
    @Published var conversationName: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var conversationMembers: [String] = [""]
    @Published var conversationMembersValidate: [Bool] = []
    @Published var conversationPicture: UIImage?
    @Published var errorText: String?

    private let myUserPhone: String
    @Injected(\.conversationsListService) private var conversationsListService

    init() {
        let user = Container.shared.userDefaultsManager().user ?? User(id: "", username: "", email: "", phone: "")
        myUserPhone = user.phone

        $conversationMembers
            .map { $0.map { self.isValidPhoneNumber($0) } }
            .assign(to: &$conversationMembersValidate)
    }


    func didClickCreate() -> Bool {
        guard !conversationMembers.filter({ isValidPhoneNumber($0) && $0.count > 3 }).isEmpty else {
            errorText = String(localized: "AddConversation.invalidPhone")
            return false
        }
        let pictureData = conversationPicture?.jpegData(compressionQuality: 1)
        let conversationName: String? = self.conversationName.isEmpty ? nil : self.conversationName
        Task {
            try await conversationsListService.createConversation(image: pictureData,
                                                                  conversationName: conversationName,
                                                                  conversationMembers: conversationMembers)
        }
        return true
    }

    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        guard !conversationMembers.contains(myUserPhone) else {
            errorText = String(localized: "AddConversation.addItself")
            return false
        }

        if phoneNumber.count <= 3 {
            return true
        }
        let phoneRegex = "^0[67]\\d{8}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePred.evaluate(with: phoneNumber)
    }
}
