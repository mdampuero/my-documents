import SwiftUI

struct DocumentDetailView: View {
    var document: Document

    var body: some View {
        Form {
            Section(header: Text("Información")) {
                Text("Nombre: \(document.name)")
                Text("Tipo: \(document.type)")
                Text("Descripción: \(document.description)")
                Text("Fecha: \(dateFormatter.string(from: document.date))")
            }
        }
        .navigationTitle(document.name)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }
}

#Preview {
    DocumentDetailView(document: Document(name: "Contrato", type: "PDF", description: "Contrato de alquiler"))
}
