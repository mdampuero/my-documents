//
//  LoginView.swift
//  my-documents
//
//  Created by Mauricio Ampuero on 8/8/25.
//

import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userEmail") private var storedEmail: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var showPassword: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("login_title")
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    TextField("email_placeholder", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5))
                        )
                    if let emailError = emailError {
                        Text(emailError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if showPassword {
                            TextField("password_placeholder", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("password_placeholder", text: $password)
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5))
                    )
                    if let passwordError = passwordError {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                HStack {
                    NavigationLink("forgot_password_link") {
                        ForgotPasswordView()
                    }
                    Spacer()
                    NavigationLink("create_account_link") {
                        CreateAccountView()
                    }
                }

                Button("login_button") {
                    validate()
                }
                .padding(.vertical, 20) // padding interior vertical
                .padding(.horizontal, 20) // padding interior horizontal
                .frame(maxWidth: .infinity) // ocupa todo el ancho
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 20) // margen exterior superior
            }
            .padding()
        }
        .onAppear {
            email = storedEmail
        }
    }

    private func validate() {
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
        if emailError == nil && passwordError == nil {
            if let user = PersistenceManager.shared.loadUser(),
               user.email == email,
               user.password == password {
                storedEmail = email
                isLoggedIn = true
            } else {
                passwordError = NSLocalizedString("invalid_credentials", comment: "")
            }
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

#Preview {
    LoginView()
}
