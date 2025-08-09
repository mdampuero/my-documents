import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct DocumentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var type: String
    @State private var description: String
    @State private var nameError: Bool = false
    @State private var showAlert: Bool = false
    @State private var attachments: [Attachment]
    @State private var showFileImporter: Bool = false
    @State private var showAddOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedFileURL: URL?
    @State private var selectedFileIsImage: Bool = false
    @State private var selectedFileLabel: String = ""
    @State private var showAttachmentPreview: Bool = false

    var document: Document?
    var onSave: (Document) -> Void

    init(document: Document?, onSave: @escaping (Document) -> Void) {
        self.document = document
        _name = State(initialValue: document?.name ?? "")
        _type = State(initialValue: document?.type ?? "")
        _description = State(initialValue: document?.description ?? "")
        _attachments = State(initialValue: document?.attachments ?? [])
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
                    VStack(alignment: .leading) {
                        Text("Descripción")
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                Section {
                    ForEach(attachments) { file in
                        HStack {
                            Image(systemName: iconName(for: file.url))
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text(file.label)
                                Text(dateFormatter.string(from: file.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                if let index = attachments.firstIndex(of: file) {
                                    attachments.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                } header: {
                    Text("Archivos")
                }
                Section {
                    Button {
                        showAddOptions = true
                    } label: {
                        Label("Agregar", systemImage: "paperclip")
                    }
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
                               date: document?.date ?? Date(),
                               attachments: attachments)
                            onSave(doc)
                            showAlert = true
                        }
                    }
                }
            }
            .alert("Documento guardado", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image, .pdf, .plainText, .data]) { result in
                switch result {
                case .success(let url):
                    let isImage = (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
                    selectedFileURL = url
                    selectedFileIsImage = isImage
                    selectedFileLabel = url.lastPathComponent
                    showAttachmentPreview = true
                case .failure(let error):
                    print("File import failed: \(error)")
                }
            }
            .confirmationDialog("Agregar archivo", isPresented: $showAddOptions, titleVisibility: .visible) {
                Button("Galería de fotos") {
                    imageSource = .photoLibrary
                    showImagePicker = true
                }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Tomar fotografía") {
                        imageSource = .camera
                        showImagePicker = true
                    }
                }
                Button("Seleccionar archivo") {
                    showFileImporter = true
                }
                Button("Cancelar", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSource) { image in
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        let filename = UUID().uuidString + ".jpg"
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                        try? data.write(to: url)
                        selectedFileURL = url
                        selectedFileIsImage = true
                        selectedFileLabel = url.lastPathComponent
                        showAttachmentPreview = true
                    }
                }
            }
            .sheet(isPresented: $showAttachmentPreview) {
                if let url = selectedFileURL {
                    AttachmentPreviewView(url: url, isImage: selectedFileIsImage, initialLabel: selectedFileLabel) { label in
                        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                        let date = attrs?[.creationDate] as? Date ?? Date()
                        attachments.append(Attachment(url: url, isImage: selectedFileIsImage, label: label, date: date))
                    }
                }
            }
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

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    DocumentFormView(document: nil) { _ in }
}
