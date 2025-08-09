import SwiftUI

struct DocumentsView: View {
    @State private var documents: [Document] = []
    @State private var showingForm = false
    @State private var documentToEdit: Document?
    @State private var documentToDelete: Document?
    @State private var showDeleteConfirmation = false
    @State private var searchText: String = ""

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
                        Button("Editar") {
                            documentToEdit = doc.wrappedValue
                            showingForm = true
                        }.tint(.blue)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Mis documentos")
            .toolbar {
                Button {
                    documentToEdit = nil
                    showingForm = true
                } label: {
                    Image(systemName: "plus")
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
            .sheet(isPresented: $showingForm) {
                DocumentFormView(document: documentToEdit) { newDoc in
                    if let index = documents.firstIndex(where: { $0.id == newDoc.id }) {
                        documents[index] = newDoc
                    } else {
                        documents.append(newDoc)
                    }
                }
            }
            .onAppear {
                documents = PersistenceManager.shared.loadDocuments()
            }
            .onChange(of: documents) { newValue in
                PersistenceManager.shared.saveDocuments(newValue)
            }
        }
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
