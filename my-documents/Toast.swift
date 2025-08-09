import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}
