import SwiftUI

struct AccountView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userEmail") private var storedEmail: String = ""

    var body: some View {
        NavigationStack {
            List {
                if !storedEmail.isEmpty {
                    Section {
                        Label(storedEmail, systemImage: "person.circle")
                    }
                }
                Section {
                    Button {
                        storedEmail = ""
                        isLoggedIn = false
                    } label: {
                        Label(NSLocalizedString("logout_button", comment: ""), systemImage: "arrow.backward.square")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("my_account_title", comment: ""))
        }
    }
}

#Preview {
    AccountView()
}
