//
//  LoginView.swift
//  my-documents
//
//  Created by Mauricio Ampuero on 8/8/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var toasts: [ToastMessage] = []

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    Text("login_title")
                        .font(.title)
                    TextField("email_placeholder", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(emailError == nil ? Color.gray.opacity(0.5) : Color.red)
                        )
                    SecureField("password_placeholder", text: $password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(passwordError == nil ? Color.gray.opacity(0.5) : Color.red)
                        )
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
                    .padding()
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                ToastStack(messages: toasts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    private func validate() {
        toasts = []
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        if let emailError = emailError {
            toasts.append(ToastMessage(text: emailError))
        }
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
        if let passwordError = passwordError {
            toasts.append(ToastMessage(text: passwordError))
        }
        if emailError == nil && passwordError == nil {
            // Authentication logic would go here
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
