import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var acceptTerms: Bool = false
    @State private var dataConsent: Bool = false

    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var termsError: String?
    @State private var dataConsentError: String?

    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            TextField("full_name_placeholder", text: $fullName)
                .autocapitalization(.words)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5))
                )
            if let fullNameError = fullNameError {
                Text(fullNameError)
                    .foregroundColor(.red)
                    .font(.caption)
            }

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

            SecureField("confirm_password_placeholder", text: $confirmPassword)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5))
                )
            if let confirmPasswordError = confirmPasswordError {
                Text(confirmPasswordError)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Toggle("accept_terms_label", isOn: $acceptTerms)
            if let termsError = termsError {
                Text(termsError)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Toggle("data_consent_label", isOn: $dataConsent)
            if let dataConsentError = dataConsentError {
                Text(dataConsentError)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("create_account_button") {
                validate()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("create_account_title")
        .alert("account_created_message", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }

    private func validate() {
        fullNameError = fullName.isEmpty ? NSLocalizedString("invalid_full_name", comment: "") : nil
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
        confirmPasswordError = (confirmPassword == password) ? nil : NSLocalizedString("passwords_do_not_match", comment: "")
        termsError = acceptTerms ? nil : NSLocalizedString("must_accept_terms", comment: "")
        dataConsentError = dataConsent ? nil : NSLocalizedString("must_consent_data", comment: "")

        if fullNameError == nil &&
            emailError == nil &&
            passwordError == nil &&
            confirmPasswordError == nil &&
            termsError == nil &&
            dataConsentError == nil {
            showAlert = true
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

#Preview {
    CreateAccountView()
}
