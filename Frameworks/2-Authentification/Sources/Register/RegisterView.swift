//
//  Register.swift
//
//
//  Created by Paul VAYSSIER on 08/04/2024.
//

import SwiftUI
import PhotosUI

public struct RegisterView<ViewModel: AuthViewModelProtocol>: View {

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject private var viewModel: ViewModel

    public var body: some View {

        VStack(alignment: .center, content: {
            ScrollView {

                Spacer(minLength: 30)

                Image("logo", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("Welcome to Whats'Up")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                    .bold()
                    .padding(.bottom, 40)

                TextField("Username", text: $viewModel.viewState.username)
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
                    .textInputAutocapitalization(.never)


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
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                TextField("Phone number", text: $viewModel.viewState.phone)
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
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)

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
                    viewModel.didTapRegister()
                }, label: {
                    Text("Register")
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
                    Text("You have an account ?")
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .padding(.bottom, 20)
                    Button(action: {
                        viewModel.viewState.password = ""
                        viewModel.updateAuthType(.login)
                    }) {
                        Text("Sign in")
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
    }
}
#if DEBUG
#Preview {
    @State var viewModel: AuthViewModel = AuthViewModel(viewState: AuthViewState(authType: .login))
    return RegisterView(viewModel: viewModel)
}
#endif
