import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationStack {
            Text("Mi cuenta")
                .navigationTitle("Mi cuenta")
        }
    }
}

#Preview {
    AccountView()
}
