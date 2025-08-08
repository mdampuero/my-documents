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
    @State private var toasts: [ToastMessage] = []

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                TextField("full_name_placeholder", text: $fullName)
                    .autocapitalization(.words)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(fullNameError == nil ? Color.gray.opacity(0.5) : Color.red)
                    )

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

                SecureField("confirm_password_placeholder", text: $confirmPassword)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(confirmPasswordError == nil ? Color.gray.opacity(0.5) : Color.red)
                    )

                Toggle("accept_terms_label", isOn: $acceptTerms)
                    .tint(termsError == nil ? .accentColor : .red)

                Toggle("data_consent_label", isOn: $dataConsent)
                    .tint(dataConsentError == nil ? .accentColor : .red)

                Button("create_account_button") {
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
        .navigationTitle("create_account_title")
        .alert("account_created_message", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }

    private func validate() {
        toasts = []
        fullNameError = fullName.isEmpty ? NSLocalizedString("invalid_full_name", comment: "") : nil
        if let fullNameError = fullNameError {
            toasts.append(ToastMessage(text: fullNameError))
        }
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        if let emailError = emailError {
            toasts.append(ToastMessage(text: emailError))
        }
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
        if let passwordError = passwordError {
            toasts.append(ToastMessage(text: passwordError))
        }
        confirmPasswordError = (confirmPassword == password) ? nil : NSLocalizedString("passwords_do_not_match", comment: "")
        if let confirmPasswordError = confirmPasswordError {
            toasts.append(ToastMessage(text: confirmPasswordError))
        }
        termsError = acceptTerms ? nil : NSLocalizedString("must_accept_terms", comment: "")
        if let termsError = termsError {
            toasts.append(ToastMessage(text: termsError))
        }
        dataConsentError = dataConsent ? nil : NSLocalizedString("must_consent_data", comment: "")
        if let dataConsentError = dataConsentError {
            toasts.append(ToastMessage(text: dataConsentError))
        }

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
