//
//  EditProfileViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import SwiftUI
import PhotosUI
import Combine
import Factory
import Models
import Tools

public protocol EditProfileViewModelProtocol: ObservableObject {
    var username: String { get set }
    var email: String { get set }
    var phone: String { get set }
    var profilePicture: Image? { get set }
    var selectedPickerPicture: PhotosPickerItem? { get set }
    var selectedPicture: UIImage? { get set }
    var isModified: Bool { get }
    var isLoading: Bool { get }
    var goToLogin: () -> Void { get }
    func didTapSave()
    func didTapLogout()
    func didTapDelete()
}

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    @Published var username: String
    @Published var email: String
    @Published var phone: String
    @Published var selectedPickerPicture: PhotosPickerItem?
    @Published var selectedPicture: UIImage?
    @Published var profilePicture: Image?
    @Published var isModified: Bool = false
    @Published var isLoading: Bool = false

    @Injected(\.editProfileService) private var editProfileService

    private let userId: String
    private var cancellables = Set<AnyCancellable>()
    let goToLogin: () -> Void

    init(picture: Image?, _ goToLogin: @escaping () -> Void) {
        let myUser = Container.shared.userDefaultsManager().user ?? User(id: "", username: "", email: "", phone: "")
        userId = myUser.id
        self.username = myUser.username
        self.email = myUser.email
        self.phone = myUser.phone
        profilePicture = picture
        self.goToLogin = goToLogin

        
        Publishers.CombineLatest4($username,
                                  $email,
                                  $phone,
                                  $selectedPicture)
        .map { username, email, phone, picture in
            if myUser.username != username
                || myUser.email != email
                || myUser.phone != phone
                || picture != nil {
                return true
            }
            return false
        }
        .assign(to: \.isModified, on: self)
        .store(in: &cancellables)
    }

    @MainActor
    func didTapSave() {
        isLoading = true
        Task {
            do {
                let profile = try await editProfileService.updateProfile(userId: userId,
                                                                                 username: username,
                                                                                 email: email,
                                                                                 phone: phone,
                                                                                 picture: selectedPicture?.jpegData(compressionQuality: 1))
                let user = User(dto: profile)
                Container.shared.userDefaultsManager().user = user

                if let pictureUrl = user.pictureUrl {
                    profilePicture = await Image.loadAsync(from: pictureUrl)
                }
                email = user.email
                phone = user.phone
                username = user.username

                isModified = false
                isLoading = false
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func didTapLogout() {
        Container.shared.userDefaultsManager().user = nil
        if KeychainHelper.deleteJWT() {
            goToLogin()
        }
    }

    func didTapDelete() {
        isLoading = true
        Task {
            do {
                let isDeleted = try await editProfileService.deleteProfile()
                if isDeleted {
                    Container.shared.userDefaultsManager().user = nil
                    _ = KeychainHelper.deleteJWT()
                    goToLogin()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
