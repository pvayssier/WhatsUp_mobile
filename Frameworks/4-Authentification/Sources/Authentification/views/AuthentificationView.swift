//
//  Authentification.swift
//
//
//  Created by Paul VAYSSIER on 09/04/2024.
//

import SwiftUI
import Models
import Tools
import Conversations

public struct AuthentificationView<ViewModel: AuthViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    private let loginView: LoginView<ViewModel>
    private let registerView: RegisterView<ViewModel>
    private let conversationsView: ConversationsListView<ConversationsListViewModel>

    @State private var isShowingAdminModal: Bool = false

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.loginView = LoginView(viewModel: viewModel)
        self.registerView = RegisterView(viewModel: viewModel)

        let conversationsListViewModel = ConversationsListViewModel(userNotLogged: viewModel.userNotLogged)
        self.conversationsView = ConversationsListView(viewModel: conversationsListViewModel)
    }

    public var body: some View {
        Group {
            if viewModel.viewState.authType == .login {
                loginView
            } else if viewModel.viewState.authType == .register {
                registerView
            } else {
                conversationsView
            }
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            isShowingAdminModal = true
        }
        .sheet(isPresented: $isShowingAdminModal) {
            AdminModal(viewModel: viewModel)
        }
    }
}

#if DEBUG
#Preview {
    @State var viewModel: AuthViewModel = AuthViewModel(viewState: AuthViewState(authType: .login))
    return AuthentificationView(viewModel: viewModel)
}
#endif
