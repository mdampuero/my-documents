import Foundation

struct Attachment: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var isImage: Bool

    init(id: UUID = UUID(), url: URL, isImage: Bool) {
        self.id = id
        self.url = url
        self.isImage = isImage
    }
}
