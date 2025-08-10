import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentDetailView: View {
    @Binding var document: Document
    @State private var showingForm = false
    @State private var selectedAttachment: Attachment?
    @State private var showFileImporter = false
    @State private var showToast = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Form {
            Section(header: Text("Información")) {
                Text("Nombre: \(document.name)")
                Text("Tipo: \(document.type)")
                Text("Descripción: \(document.description)")
                Text("Fecha: \(dateFormatter.string(from: document.date))")
            }

            if !document.attachments.isEmpty {
                Section(header: Text("Archivos")) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(document.attachments) { attachment in
                            attachmentView(for: attachment)
                                .onTapGesture {
                                    selectedAttachment = attachment
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(document.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showFileImporter = true
                } label: {
                    Image(systemName: "paperclip")
                }
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
        .sheet(item: $selectedAttachment) { attachment in
            AttachmentPreviewView(url: attachment.url, isImage: attachment.isImage, initialLabel: attachment.label) { label in
                if let index = document.attachments.firstIndex(where: { $0.id == attachment.id }) {
                    document.attachments[index].label = label
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image, .pdf, .plainText, .data]) { result in
            switch result {
            case .success(let url):
                let isImage = (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
                if let savedURL = PersistenceManager.shared.saveAttachment(from: url) {
                    let attachment = Attachment(url: savedURL, isImage: isImage, label: url.lastPathComponent)
                    document.attachments.append(attachment)
                    showToast = true
                }
            case .failure(let error):
                print("File import failed: \(error)")
            }
        }
        .toast(message: "Archivo guardado", isPresented: $showToast)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }

    @ViewBuilder
    private func attachmentView(for attachment: Attachment) -> some View {
        if attachment.isImage, let image = UIImage(contentsOfFile: attachment.url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
        } else {
            Image(systemName: iconName(for: attachment.url))
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(10)
        }
    }

    private func iconName(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return "doc.richtext"
        case "txt":
            return "doc.text"
        case "zip":
            return "archivebox"
        default:
            return "doc"
        }
    }
}

#Preview {
    DocumentDetailView(document: .constant(Document(name: "Contrato", type: "PDF", description: "Contrato de alquiler")))
}
