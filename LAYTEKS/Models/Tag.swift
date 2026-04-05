import SwiftData
import Foundation

@Model
final class Tag {
    var id: UUID
    var name: String

    @Relationship(deleteRule: .nullify)
    var notes: [Note]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.notes = []
    }
}
