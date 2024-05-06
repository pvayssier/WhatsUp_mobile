//
//  Login.swift
//
//
//  Created by Paul VAYSSIER on 08/04/2024.
//

import SwiftUI
import PhotosUI

struct LoginView<ViewModel: AuthViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

            VStack(alignment: .center, content: {
                ScrollView {

                    Spacer(minLength: 30)
                    Image("logo", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text(String(localized: "Login.title"))
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                        .bold()
                        .padding(.bottom, 40)

                    TextField(String(localized: "Login.phone"), text: $viewModel.viewState.phone)
                        .padding(.horizontal, 10)
                        .frame(height: 50)
                        .background(Color("textField_color", bundle: .module))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.isValidPhoneNumber ? .green : .red, lineWidth: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .autocorrectionDisabled(true)
                        .onChange(of: viewModel.viewState.phone) { newValue in
                            if newValue.count > 10 {
                                viewModel.viewState.phone = String(viewModel.viewState.phone.prefix(10))
                            }
                        }
                    HStack {
                        Text(String(localized: "Login.phoneError"))
                            .font(.caption)
                            .foregroundColor(!viewModel.isValidPhoneNumber ? .red : .clear)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        Spacer()
                    }
                    SecureField(String(localized: "Login.password"), text: $viewModel.viewState.password)
                        .padding(.horizontal, 10)
                        .frame(height: 50)
                        .background(Color("textField_color", bundle: .module))
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.isValidPassword ? .green : .red, lineWidth: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    if !viewModel.isValidPassword {
                        HStack {
                            Text(String(localized: "Login.passwordError"))
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                            Spacer()
                        }
                    }
                    if let error = viewModel.authentificationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                            .padding(.top, 20)
                    }
                    Button(action: {
                        viewModel.didTapLogin()
                    }, label: {
                        Text(String(localized: "Login.button"))
                            .frame(maxWidth: .infinity)
                    })
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, viewModel.authentificationError == nil ? 20 : 4)

                    HStack {
                        Text(String(localized: "Login.dontHaveAccount"))
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                            .padding(.bottom, 20)
                        Button(action: {
                            viewModel.viewState.password = ""
                            viewModel.updateAuthType(.register)
                        }) {
                            Text(String(localized: "Login.signup"))
                                .multilineTextAlignment(.leading)
                                .font(.callout)
                                .padding(.bottom, 20)
                                .foregroundColor(.green)
                        }
                        Spacer()
                    }
                    .padding(.leading, 24)
                    Spacer()
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(uiColor: UIColor.systemGray6))
            })
            .background(Color(uiColor: UIColor.systemGray6))
            .ignoresSafeArea(.keyboard)
    }
}

#if DEBUG
#Preview {
    @State var viewModel: AuthViewModel = AuthViewModel(viewState: AuthViewState(authType: .login))
    return LoginView(viewModel: viewModel)
}
#endif
