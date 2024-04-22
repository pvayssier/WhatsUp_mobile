//
//  AddConversationViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 20/04/2024.
//

import SwiftUI
import PhotosUI
import Factory

protocol AddConversationViewModelProtocol: ObservableObject {
    var conversationName: String { get set }
    var conversationMembers: [String] { get set }
    var selectedPhoto: PhotosPickerItem? { get set }
    var conversationPicture: UIImage? { get set }

    func didClickCreate()
}

final class AddConversationViewModel: AddConversationViewModelProtocol, ObservableObject {
    @Published var conversationName: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var conversationMembers: [String] = [""]
    @Published var conversationPicture: UIImage?

    @Injected(\.conversationsListService) private var conversationsListService

    func didClickCreate() {
        let pictureData = conversationPicture?.jpegData(compressionQuality: 1)
        let conversationName: String? = self.conversationName.isEmpty ? nil : self.conversationName
        Task {
            try await conversationsListService.createConversation(image: pictureData,
                                                                  conversationName: conversationName,
                                                                  conversationMembers: conversationMembers)
        }
    }
}
