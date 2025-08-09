import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let userURL: URL
    private let documentsURL: URL
    private let attachmentsDirectory: URL

    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        userURL = directory.appendingPathComponent("user.json")
        documentsURL = directory.appendingPathComponent("documents.json")
        attachmentsDirectory = directory.appendingPathComponent("attachments")
        try? FileManager.default.createDirectory(at: attachmentsDirectory, withIntermediateDirectories: true)
    }

    // MARK: - User
    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            try data.write(to: userURL, options: .atomic)
        } catch {
            print("Error saving user: \(error)")
        }
    }

    func loadUser() -> User? {
        guard let data = try? Data(contentsOf: userURL) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Documents
    func saveDocuments(_ documents: [Document]) {
        do {
            let data = try JSONEncoder().encode(documents)
            try data.write(to: documentsURL, options: .atomic)
        } catch {
            print("Error saving documents: \(error)")
        }
    }

    func loadDocuments() -> [Document] {
        guard let data = try? Data(contentsOf: documentsURL) else { return [] }
        return (try? JSONDecoder().decode([Document].self, from: data)) ?? []
    }

    // MARK: - Attachments
    func saveAttachment(from url: URL) -> URL? {
        let destination = attachmentsDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: url, to: destination)
            return destination
        } catch {
            print("Error saving attachment: \(error)")
            return nil
        }
    }
}

