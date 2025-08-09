import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DocumentsView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Mis documentos")
                }
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notificaciones")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Configuración")
                }
            AccountView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Mi cuenta")
                }
        }
    }
}

#Preview {
    MainTabView()
}
