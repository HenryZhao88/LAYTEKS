import SwiftData
import Foundation

@Model
final class Tag {
    var id: UUID
    var name: String

    // Inverse declared on Note.tags — no annotation needed here
    var notes: [Note]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.notes = []
    }
}
