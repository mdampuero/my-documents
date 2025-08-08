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
        VStack(spacing: 16) {
            Text("login_title")
                .font(.title)
            TextField("email_placeholder", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            if let emailError = emailError {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            SecureField("password_placeholder", text: $password)
                .textFieldStyle(.roundedBorder)
            if let passwordError = passwordError {
                Text(passwordError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Button("login_button") {
                validate()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
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
