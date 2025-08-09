import SwiftUI
import UIKit

struct ResetPasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("reset_password_description")
                .font(.body)

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

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if showConfirmPassword {
                        TextField("confirm_password_placeholder", text: $confirmPassword)
                            .autocapitalization(.none)
                    } else {
                        SecureField("confirm_password_placeholder", text: $confirmPassword)
                    }
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
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
            }

            Button("reset_password_button") {
                validate()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle("reset_password_title")
    }

    private func validate() {
        passwordError = password.count >= 6 ? nil : NSLocalizedString("invalid_password", comment: "")
        confirmPasswordError = (confirmPassword == password) ? nil : NSLocalizedString("passwords_do_not_match", comment: "")

        if passwordError == nil && confirmPasswordError == nil {
            showSuccessAlert()
        }
    }

    private func showSuccessAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController else {
            navigateToLogin()
            return
        }

        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("password_reset_message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            navigateToLogin()
        })
        root.present(alert, animated: true)
    }

    private func navigateToLogin() {
        dismiss()
        DispatchQueue.main.async {
            dismiss()
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
}

#Preview {
    ResetPasswordView()
}
