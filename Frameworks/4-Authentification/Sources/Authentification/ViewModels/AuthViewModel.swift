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
    func viewDidAppear()
    func updateAuthType(_: AuthType)
    func didTapRegister()
    func didTapLogin()
    func userNotLogged()
}

public class AuthViewModel: AuthViewModelProtocol, ObservableObject {

    @Published public var viewState: AuthViewState

    @Injected(\.authentificationService) private var authentificationService
    @Injected(\.userDefaultsManager) private var userDefaultsManager

    public init(viewState: AuthViewState) {
        self.viewState = viewState
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
    }

    public func userNotLogged() {
        Task {
            await updateAuthType(.login)
        }
    }

    @MainActor
    public func didTapRegister() {
        let user = User(id: UUID().uuidString,
                        username: viewState.username,
                        email: viewState.email,
                        phone: viewState.phone)

        Task {
            let connectionSuccessed = await authentificationService.createAccount(user: user,
                                                                                  password: viewState.password)

            if connectionSuccessed {
                updateAuthType(.authentified)
            }
        }
    }

    @MainActor
    public func didTapLogin() {
        Task {
            let connectionSuccessed = await authentificationService.login(phone: viewState.phone,
                                                                          password: viewState.password)
            if connectionSuccessed {
                updateAuthType(.authentified)
            }
        }
    }
}
