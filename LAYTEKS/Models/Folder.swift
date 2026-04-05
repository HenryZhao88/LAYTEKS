import SwiftData
import Foundation

@Model
final class Folder {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var notes: [Note]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.notes = []
    }
}
