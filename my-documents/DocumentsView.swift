import SwiftUI

struct DocumentsView: View {
    @State private var documents: [Document] = []
    @State private var documentToDelete: Document?
    @State private var showDeleteConfirmation = false
    @State private var searchText: String = ""
    @State private var showToast: Bool = false
    @State private var newDocument = Document(name: "", type: "", description: "")
    @State private var isPresentingNewDocument = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredDocuments) { doc in
                    NavigationLink(destination: DocumentDetailView(document: doc)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(doc.wrappedValue.name)
                                    .font(.headline)
                                Text(dateFormatter.string(from: doc.wrappedValue.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(doc.wrappedValue.type)
                                .font(.caption)
                                .padding(4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .badge(doc.wrappedValue.attachments.count)
                    .swipeActions(edge: .trailing) {
                        Button("Eliminar", role: .destructive) {
                            documentToDelete = doc.wrappedValue
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Mis documentos")
            .toolbar {
                Button {
                    newDocument = Document(name: "", type: "", description: "")
                    isPresentingNewDocument = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isPresentingNewDocument) {
                NavigationStack {
                    DocumentDetailView(document: $newDocument, onSave: { newDoc in
                        documents.append(newDoc)
                        showToast = true
                    })
                }
            }
            .confirmationDialog("¿Eliminar documento?", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    if let doc = documentToDelete, let index = documents.firstIndex(of: doc) {
                        documents.remove(at: index)
                    }
                }
                Button("Cancelar", role: .cancel) { }
            }
            .onAppear {
                documents = PersistenceManager.shared.loadDocuments()
            }
            .onChange(of: documents) { newValue in
                PersistenceManager.shared.saveDocuments(newValue)
            }
        }
        .toast(message: "Documento guardado", isPresented: $showToast)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }

    private var filteredDocuments: [Binding<Document>] {
        if searchText.isEmpty {
            return Array($documents)
        } else {
            return $documents.filter { $0.wrappedValue.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    DocumentsView()
}
