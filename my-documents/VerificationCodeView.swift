import SwiftUI

struct VerificationCodeView: View {
    @State private var code: [String] = Array(repeating: "", count: 6)
    @State private var codeError: String?
    @State private var navigateToReset: Bool = false
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("enter_code_description")
                .font(.body)

            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $code[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5))
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: code[index]) { newValue in
                            if newValue.count > 1 {
                                code[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty {
                                if index < 5 {
                                    focusedField = index + 1
                                } else {
                                    focusedField = nil
                                }
                            } else if index > 0 {
                                focusedField = index - 1
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)

            if let codeError = codeError {
                Text(codeError)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            NavigationLink(destination: ResetPasswordView(), isActive: $navigateToReset) {
                EmptyView()
            }

            Button("validate_code_button") {
                validate()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 20)
        }
        .padding()
        .onAppear {
            focusedField = 0
        }
        .navigationTitle("verify_code_title")
    }

    private func validate() {
        let isComplete = code.allSatisfy { $0.count == 1 }
        guard isComplete else {
            codeError = NSLocalizedString("incomplete_code_error", comment: "")
            return
        }
        let entered = code.joined()
        if entered == "123456" {
            codeError = nil
            navigateToReset = true
        } else {
            codeError = NSLocalizedString("invalid_code_error", comment: "")
        }
    }
}

#Preview {
    VerificationCodeView()
}
