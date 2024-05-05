//
//  AdminModal.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import SwiftUI
import Factory

struct AdminModal<ViewModel: AuthViewModelProtocol>: View {

    @Environment(\.dismiss) private var dismiss
    @Injected(\.userDefaultsManager) private var userDefaultsManager

    @State private var baseURL: String = Container.shared.userDefaultsManager().baseURL ?? "http://172.16.70.196:3000/"
    @State private var type: AuthType = .login

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Base URL")) {
                    TextField("Enter Base URL", text: $baseURL)
                }
                Section(header: Text("Authentication Step")) {
                    Picker("Choose a step", selection: $type) {
                        ForEach(AuthType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Admin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: {
                        dismiss()
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Change") {
                        didTapChange()
                        viewModel.updateAuthType(type)
                        dismiss()
                    }
                }
            }
            .onAppear {
                type = viewModel.viewState.authType
            }
        }
        .presentationDetents([.medium])
        .background(Color(.systemGray6))
    }

    private func didTapChange() {
        if baseURL.last != Character("/") {
            baseURL += "/"
        }
        userDefaultsManager.baseURL = baseURL
    }
}
