//
//  Authentification.swift
//
//
//  Created by Paul VAYSSIER on 09/04/2024.
//

import SwiftUI
import Tools

public struct Authentification<ViewModel: AuthViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    private let loginView: LoginView<ViewModel>
    private let registerView: RegisterView<ViewModel>

    @State private var isShowingAdminModal: Bool = false

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.loginView = LoginView(viewModel: viewModel)
        self.registerView = RegisterView(viewModel: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.viewState.authType == .login {
                loginView
            } else if viewModel.viewState.authType == .register {
                registerView
            } else {
                Text("I'm authentified")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            isShowingAdminModal = true
        }
        .sheet(isPresented: $isShowingAdminModal) {
            AdminModal(viewModel: viewModel)
        }
    }
}

#Preview {
    @State var viewModel: AuthViewModel = AuthViewModel(viewState: AuthViewState(authType: .login))
    return Authentification(viewModel: viewModel)
}

