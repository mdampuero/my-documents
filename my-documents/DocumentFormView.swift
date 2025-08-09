import SwiftUI

struct DocumentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var type: String
    @State private var description: String
    @State private var nameError: Bool = false
    @State private var showAlert: Bool = false

    var document: Document?
    var onSave: (Document) -> Void

    init(document: Document?, onSave: @escaping (Document) -> Void) {
        self.document = document
        _name = State(initialValue: document?.name ?? "")
        _type = State(initialValue: document?.type ?? "")
        _description = State(initialValue: document?.description ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $name)
                    if nameError {
                        Text("El nombre es obligatorio")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    TextField("Tipo", text: $type)
                    TextField("Descripción", text: $description)
                }
            }
            .navigationTitle(document == nil ? "Nuevo documento" : "Editar documento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if name.trimmingCharacters(in: .whitespaces).isEmpty {
                            nameError = true
                        } else {
                            nameError = false
                            let doc = Document(id: document?.id ?? UUID(),
                                               name: name,
                                               type: type,
                                               description: description,
                                               date: document?.date ?? Date())
                            onSave(doc)
                            showAlert = true
                        }
                    }
                }
            }
            .alert("Documento guardado", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            }
        }
    }
}

#Preview {
    DocumentFormView(document: nil) { _ in }
}
