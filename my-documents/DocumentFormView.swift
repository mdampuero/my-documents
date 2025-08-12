import SwiftUI
import UniformTypeIdentifiers
import UIKit
import AVFoundation

struct DocumentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var type: String
    @State private var description: String
    @State private var nameError: Bool = false
    @State private var attachments: [Attachment]
    @State private var showFileImporter: Bool = false
    @State private var showAddOptions: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showCameraPermissionAlert: Bool = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedFileURL: URL?
    @State private var selectedFileIsImage: Bool = false
    @State private var selectedFileLabel: String = ""
    @State private var showAttachmentPreview: Bool = false
    @State private var attachmentToDelete: Attachment?
    @State private var nextAttachmentNumber: Int
    @State private var selectedImage: UIImage?
    @State private var editingAttachmentID: UUID?

    var document: Document?
    var onSave: (Document) -> Void

    init(document: Document?, onSave: @escaping (Document) -> Void) {
        self.document = document
        _name = State(initialValue: document?.name ?? "")
        _type = State(initialValue: document?.type ?? "")
        _description = State(initialValue: document?.description ?? "")
        _attachments = State(initialValue: document?.attachments ?? [])
        _nextAttachmentNumber = State(initialValue: DocumentFormView.nextNumber(for: document?.attachments ?? []))
        self.onSave = onSave
    }

    var body: some View {
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
                            Button {
                                attachmentToDelete = file
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFileURL = file.url
                            selectedFileIsImage = file.isImage
                            selectedFileLabel = file.label
                            selectedImage = file.isImage ? UIImage(contentsOfFile: file.url.path) : nil
                            editingAttachmentID = file.id
                            showAttachmentPreview = true
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
        .alert(item: $attachmentToDelete) { file in
            Alert(
                title: Text("Eliminar archivo"),
                message: Text("¿Deseas eliminar \(file.label)?"),
                primaryButton: .destructive(Text("Eliminar")) {
                    attachments.removeAll { $0.id == file.id }
                },
                secondaryButton: .cancel()
            )
        }
        .navigationTitle(document == nil ? "Nuevo documento" : "Editar documento")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
                        dismiss()
                    }
                }
            }
        }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image, .pdf, .plainText, .data]) { result in
                switch result {
                case .success(let url):
                    let isImage = (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
                    selectedFileURL = url
                    selectedFileIsImage = isImage
                    selectedFileLabel = defaultAttachmentLabel()
                    selectedImage = isImage ? UIImage(contentsOfFile: url.path) : nil
                    editingAttachmentID = nil
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
                        solicitarPermisoCamara { autorizado in
                            if autorizado {
                                imageSource = .camera
                                showImagePicker = true
                            } else {
                                showCameraPermissionAlert = true
                            }
                        }
                    }
                }
                Button("Seleccionar archivo") {
                    showFileImporter = true
                }
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Acceso a la cámara deshabilitado", isPresented: $showCameraPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Por favor habilita el acceso a la cámara en Configuración.")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSource) { image in
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        let filename = UUID().uuidString + ".jpg"
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                        try? data.write(to: url)
                        selectedFileURL = url
                        selectedFileIsImage = true
                        selectedFileLabel = defaultAttachmentLabel()
                        selectedImage = image
                        editingAttachmentID = nil
                        showAttachmentPreview = true
                    }
                }
            }
        .sheet(isPresented: $showAttachmentPreview, onDismiss: {
            selectedImage = nil
            selectedFileURL = nil
            editingAttachmentID = nil
        }) {
            if let url = selectedFileURL {
                AttachmentPreviewView(url: url, isImage: selectedFileIsImage, initialLabel: selectedFileLabel, image: selectedImage) { label in
                    if let editingID = editingAttachmentID, let index = attachments.firstIndex(where: { $0.id == editingID }) {
                        attachments[index].label = label
                    } else {
                        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                        let date = attrs?[.creationDate] as? Date ?? Date()
                        let savedURL = PersistenceManager.shared.saveAttachment(from: url) ?? url
                        attachments.append(Attachment(url: savedURL, isImage: selectedFileIsImage, label: label, date: date))
                        nextAttachmentNumber += 1
                    }
                }
            }
        }
    }

    private func solicitarPermisoCamara(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
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

    private func defaultAttachmentLabel() -> String {
        "Archivo \(nextAttachmentNumber)"
    }

    private static func nextNumber(for attachments: [Attachment]) -> Int {
        let prefix = "Archivo "
        let numbers = attachments.compactMap { attachment -> Int? in
            guard attachment.label.hasPrefix(prefix) else { return nil }
            return Int(attachment.label.dropFirst(prefix.count))
        }
        return (numbers.max() ?? 0) + 1
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
