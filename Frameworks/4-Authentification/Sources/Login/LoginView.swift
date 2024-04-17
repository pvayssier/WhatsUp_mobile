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

                    TextField("Email", text: $viewModel.viewState.email)
                        .padding(.horizontal, 10)
                        .frame(height: 50)
                        .background(Color("textField_color", bundle: .module))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.green, lineWidth: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled(true)

                    SecureField("Password", text: $viewModel.viewState.password)
                        .padding(.horizontal, 10)
                        .frame(height: 50)
                        .background(Color("textField_color", bundle: .module))
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.green, lineWidth: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)

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
                    .padding(.top, 20)

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
