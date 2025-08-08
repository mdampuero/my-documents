import SwiftUI

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

struct ToastStack: View {
    let messages: [ToastMessage]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(messages) { toast in
                Text(toast.text)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
