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

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("login_title")
                    .font(.title)
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
            SecureField("password_placeholder", text: $password)
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
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 16)
            }
            .padding()
        }
    }

    private func validate() {
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
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
