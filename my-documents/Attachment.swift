import Foundation

struct Attachment: Identifiable, Equatable {
    let id: UUID
    var url: URL
    var isImage: Bool
    var label: String
    var date: Date

    init(id: UUID = UUID(), url: URL, isImage: Bool, label: String? = nil, date: Date = Date()) {
        self.id = id
        self.url = url
        self.isImage = isImage
        self.label = label ?? url.lastPathComponent
        self.date = date
    }
}
