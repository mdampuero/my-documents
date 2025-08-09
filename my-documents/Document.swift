import Foundation

struct Document: Identifiable, Equatable {
    let id: UUID
    var name: String
    var type: String
    var description: String
    var date: Date

    init(id: UUID = UUID(), name: String, type: String, description: String, date: Date = Date()) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.date = date
    }
}
