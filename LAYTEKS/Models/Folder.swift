import SwiftData
import Foundation

@Model
final class Folder {
    var id: UUID
    var name: String
    var createdAt: Date

    // Inverse declared on Note.folder — no annotation needed here
    var notes: [Note]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.notes = []
    }
}
