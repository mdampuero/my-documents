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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(attachments) { file in
                            ZStack(alignment: .topTrailing) {
                                if file.isImage, let image = UIImage(contentsOfFile: file.url.path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                } else {
                                    Image(systemName: iconName(for: file.url))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .frame(width: 80, height: 80)
                                }
                                Button {
                                    if let index = attachments.firstIndex(of: file) {
                                        attachments.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .offset(x: -4, y: 4)
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
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image, .pdf, .plainText, .data], allowsMultipleSelection: true) { result in
                switch result {
                case .success(let urls):
                    for url in urls {
                        let isImage = (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
                        attachments.append(Attachment(url: url, isImage: isImage))
                    }
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
                        attachments.append(Attachment(url: url, isImage: true))
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
