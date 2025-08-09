import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [String] = [
        "Documento A actualizado",
        "Nuevo mensaje",
        "Recordatorio de pago"
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(notifications, id: \.self) { item in
                    Text(item)
                }
                .onDelete { indices in
                    notifications.remove(atOffsets: indices)
                }
            }
            .navigationTitle("Notificaciones")
        }
    }
}

#Preview {
    NotificationsView()
}
