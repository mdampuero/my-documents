import SwiftUI
import UIKit
import UniformTypeIdentifiers
import AVFoundation

struct DocumentDetailView: View {
    @Binding var document: Document
    @Environment(\.dismiss) private var dismiss
    var onSave: ((Document) -> Void)?

    @State private var isEditing = false
    @State private var nameError = false
    @State private var selectedAttachment: Attachment?
    @State private var attachmentToDelete: Attachment?
    @State private var showFileImporter = false
    @State private var showAddOptions = false
    @State private var showImagePicker = false
    @State private var showCameraPermissionAlert = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedFileURL: URL?
    @State private var selectedFileIsImage: Bool = false
    @State private var selectedFileLabel: String = ""
    @State private var showAttachmentPreview = false
    @State private var nextAttachmentNumber: Int
    @State private var selectedImage: UIImage?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    init(document: Binding<Document>, onSave: ((Document) -> Void)? = nil) {
        _document = document
        self.onSave = onSave
        _isEditing = State(initialValue: onSave != nil)
        _nextAttachmentNumber = State(initialValue: DocumentDetailView.nextNumber(for: document.wrappedValue.attachments))
    }

    var body: some View {
        Form {
            Section(header: Text("Información")) {
                TextField("Nombre", text: $document.name)
                    .disabled(!isEditing)
                if nameError {
                    Text("El nombre es obligatorio")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                TextField("Tipo", text: $document.type)
                    .disabled(!isEditing)
                VStack(alignment: .leading) {
                    Text("Descripción")
                    TextEditor(text: $document.description)
                        .frame(minHeight: 100)
                        .disabled(!isEditing)
                }
                Text("Fecha: \(dateFormatter.string(from: document.date))")
            }

            Section(header: Text("Archivos")) {
                if !document.attachments.isEmpty {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(document.attachments) { attachment in
                            ZStack(alignment: .topTrailing) {
                                attachmentView(for: attachment)
                                    .onTapGesture {
                                        selectedAttachment = attachment
                                    }
                                if isEditing {
                                    Button {
                                        attachmentToDelete = attachment
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Button {
                    showAddOptions = true
                } label: {
                    Label("Agregar", systemImage: "paperclip")
                }
                .disabled(!isEditing)
            }
        }
        .navigationTitle(onSave == nil ? document.name : "Nuevo documento")
        .toolbar {
            if onSave == nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Guardar" : "Editar") {
                        isEditing.toggle()
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        if document.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            nameError = true
                        } else {
                            nameError = false
                            onSave?(document)
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedAttachment) { attachment in
            AttachmentPreviewView(url: attachment.url, isImage: attachment.isImage, initialLabel: attachment.label, allowEditing: isEditing) { label in
                if let index = document.attachments.firstIndex(where: { $0.id == attachment.id }) {
                    document.attachments[index].label = label
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
        .confirmationDialog("¿Eliminar archivo?", isPresented: Binding(
            get: { attachmentToDelete != nil },
            set: { if !$0 { attachmentToDelete = nil } }
        )) {
            Button("Eliminar", role: .destructive) {
                if let attachment = attachmentToDelete,
                   let index = document.attachments.firstIndex(where: { $0.id == attachment.id }) {
                    document.attachments.remove(at: index)
                }
                attachmentToDelete = nil
            }
            Button("Cancelar", role: .cancel) {
                attachmentToDelete = nil
            }
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
                    showAttachmentPreview = true
                }
            }
        }
        .sheet(isPresented: $showAttachmentPreview, onDismiss: {
            selectedFileURL = nil
            selectedImage = nil
        }) {
            if let url = selectedFileURL {
                AttachmentPreviewView(url: url, isImage: selectedFileIsImage, initialLabel: selectedFileLabel, image: selectedImage) { label in
                    let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let date = attrs?[.creationDate] as? Date ?? Date()
                    let savedURL = PersistenceManager.shared.saveAttachment(from: url) ?? url
                    document.attachments.append(Attachment(url: savedURL, isImage: selectedFileIsImage, label: label, date: date))
                    nextAttachmentNumber += 1
                }
            }
        }
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

#Preview {
    DocumentDetailView(document: .constant(Document(name: "Contrato", type: "PDF", description: "Contrato de alquiler")))
}
