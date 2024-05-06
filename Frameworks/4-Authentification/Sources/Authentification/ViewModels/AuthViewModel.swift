//
//  AuthViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 09/04/2024.
//

import Foundation
import Factory
import Models
import Tools

public protocol AuthViewModelProtocol: ObservableObject {
    var viewState: AuthViewState { get set }
    var isLoading: Bool { get }

    var isValidEmail: Bool { get }
    var isValidPhoneNumber: Bool { get }
    var isValidPassword: Bool { get }
    var authentificationError: String? { get }

    func viewDidAppear()
    func updateAuthType(_: AuthType)
    func didTapRegister()
    func didTapLogin()
    func userNotLogged()
}

public class AuthViewModel: AuthViewModelProtocol, ObservableObject {

    @Published public var viewState: AuthViewState
    @Published public var isLoading: Bool = false
    @Published public var isValidEmail: Bool = true
    @Published public var isValidPhoneNumber: Bool = true
    @Published public var isValidPassword: Bool = true
    @Published public var authentificationError: String?

    @Injected(\.authentificationService) private var authentificationService
    @Injected(\.userDefaultsManager) private var userDefaultsManager

    public init(viewState: AuthViewState) {
        self.viewState = viewState

        $viewState
            .map { [weak self] viewState in
                guard let self = self, viewState.email.count > 2 else { return true }
                return self.isValidEmail(viewState.email)
            }
            .assign(to: &$isValidEmail)

        $viewState
            .map { [weak self] viewState in
                guard let self = self, viewState.phone.count > 2 else { return true }
                return self.isValidPhoneNumber(viewState.phone)
            }
            .assign(to: &$isValidPhoneNumber)

        isValidEmail = true
        isValidPhoneNumber = true
        isValidPassword = true
    }

    @MainActor
    public func viewDidAppear() {
        if userDefaultsManager.user != nil {
            updateAuthType(.authentified)
        }
    }

    @MainActor
    public func updateAuthType(_ value: AuthType) {
        viewState.authType = value
        isValidPassword = true
    }

    public func userNotLogged() {
        Task {
            await updateAuthType(.login)
        }
    }

    @MainActor
    public func didTapRegister() {
        isValidEmail = isValidEmail(viewState.email)
        isValidPhoneNumber = isValidPhoneNumber(viewState.phone)
        isValidPassword = isValidPassword(viewState.password)
        guard isValidEmail
                && isValidPhoneNumber
                && isValidPassword else { return }
        isLoading = true
        let user = User(id: UUID().uuidString,
                        username: viewState.username,
                        email: viewState.email,
                        phone: viewState.phone)

        Task {
            do {
                let connectionSuccessed = try await authentificationService.createAccount(user: user,
                                                                                          password: viewState.password)
                isLoading = false
                if connectionSuccessed {
                    updateAuthType(.authentified)
                }
            } catch {
                debugPrint(error)
                if let error = error as? NetworkError, error == NetworkError.badRequest {
                    authentificationError = String(localized: "Register.credentialsError")
                } else {
                    authentificationError = error.localizedDescription
                }
                isLoading = false
            }
        }
    }

    @MainActor
    public func didTapLogin() {
        isValidPhoneNumber = isValidPhoneNumber(viewState.phone)
        isValidPassword = isValidPassword(viewState.password)
        guard isValidPhoneNumber && isValidPassword else { return }
        isLoading = true
        Task {
            do {
                let connectionSuccessed = try await authentificationService.login(phone: viewState.phone,
                                                                              password: viewState.password)
                isLoading = false
                if connectionSuccessed {
                    updateAuthType(.authentified)
                }
            } catch {
                if let error = error as? NetworkError, error == NetworkError.unauthorized {
                    authentificationError = String(localized: "Login.credentialsError")
                } else {
                    authentificationError = error.localizedDescription
                }
                isLoading = false
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^0[67]\\d{8}$"

        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePred.evaluate(with: phoneNumber)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_])[A-Za-z\\d\\W_]{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPred.evaluate(with: password)
    }
}
