import SwiftUI

struct DocumentDetailView: View {
    @Binding var document: Document
    @State private var showingForm = false

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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    showingForm = true
                }
            }
        }
        .sheet(isPresented: $showingForm) {
            DocumentFormView(document: document) { updatedDoc in
                document = updatedDoc
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }
}

#Preview {
    DocumentDetailView(document: .constant(Document(name: "Contrato", type: "PDF", description: "Contrato de alquiler")))
}
