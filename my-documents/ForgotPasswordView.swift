import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var emailError: String?
    @State private var navigateToCode: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("forgot_password_description")
                .font(.body)

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

            NavigationLink(destination: VerificationCodeView(), isActive: $navigateToCode) {
                EmptyView()
            }

            Button("send_code_button") {
                validate()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle("forgot_password_title")
    }

    private func validate() {
        emailError = isValidEmail(email) ? nil : NSLocalizedString("invalid_email", comment: "")
        if emailError == nil {
            navigateToCode = true
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

#Preview {
    ForgotPasswordView()
}
