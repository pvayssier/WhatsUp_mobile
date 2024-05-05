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

                    Text("Login to WhatsUp")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                        .bold()
                        .padding(.bottom, 40)

                    TextField("Phone number", text: $viewModel.viewState.phone)
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
                        Text("Invalid phone number")
                            .font(.caption)
                            .foregroundColor(!viewModel.isValidPhoneNumber ? .red : .clear)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        Spacer()
                    }
                    SecureField("Password", text: $viewModel.viewState.password)
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
                            Text("""
Password must contain at least:
- 8 characters
- 1 uppercase letter
- 1 lowercase letter
- 1 number
- 1 special character
""")
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
                        Text("Login")
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
                        Text("You don't have an account ?")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                            .padding(.bottom, 20)
                        Button(action: {
                            viewModel.viewState.password = ""
                            viewModel.updateAuthType(.register)
                        }) {
                            Text("Sign up")
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
