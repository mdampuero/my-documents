import SwiftUI
import UIKit

struct AttachmentPreviewView: View {
    var url: URL
    var isImage: Bool
    var initialLabel: String
    var image: UIImage?
    var onSave: (String) -> Void
    @State private var label: String
    @Environment(\.dismiss) private var dismiss

    init(url: URL, isImage: Bool, initialLabel: String, image: UIImage? = nil, onSave: @escaping (String) -> Void) {
        self.url = url
        self.isImage = isImage
        self.initialLabel = initialLabel
        self.image = image
        self.onSave = onSave
        _label = State(initialValue: initialLabel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isImage {
                    if let uiImage = image ?? UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                } else {
                    Image(systemName: iconName(for: url))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                TextField("Nombre", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
            }
            .navigationTitle("Vista previa")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(label)
                        dismiss()
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

#Preview {
    AttachmentPreviewView(url: URL(fileURLWithPath: "/tmp/test.pdf"), isImage: false, initialLabel: "test.pdf") { _ in }
}
