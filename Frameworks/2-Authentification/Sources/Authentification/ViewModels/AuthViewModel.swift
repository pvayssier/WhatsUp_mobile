//
//  AuthViewModel.swift
//  
//
//  Created by Paul VAYSSIER on 09/04/2024.
//

import Foundation
import Factory
import Models

public protocol AuthViewModelProtocol: ObservableObject {
    var viewState: AuthViewState { get set }
    var isAnimating: Bool { get }
    func updateAuthType(_: AuthType)
    func didTapRegister()
    func didTapLogin()
}

public class AuthViewModel: AuthViewModelProtocol, ObservableObject {

    @Published public var viewState: AuthViewState
    public var isAnimating = false

    @Injected(\.authentificationService) private var authentificationService

    public init(viewState: AuthViewState) {
        self.viewState = viewState
    }

    @MainActor
    public func updateAuthType(_ value: AuthType) {
        viewState.authType = value
        isAnimating.toggle()
    }

    @MainActor
    public func didTapRegister() {
        let user = User(id: UUID().uuidString,
                        username: viewState.username,
                        email: viewState.email,
                        phone: viewState.phone)

        authentificationService.createAccount(user: user, password: viewState.password)
    }

    @MainActor
    public func didTapLogin() {
        Task {
            let connectionSuccessed = await authentificationService.login(authentId: viewState.email, 
                                                                          password: viewState.password)
            if connectionSuccessed {
                updateAuthType(.authentified)
            }
        }
    }
}
