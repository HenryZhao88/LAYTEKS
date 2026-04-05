import SwiftData
import Foundation

@Model
final class Note {
    var id: UUID
    var title: String
    var latexSource: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Folder.notes)
    var folder: Folder?

    @Relationship(deleteRule: .nullify, inverse: \Tag.notes)
    var tags: [Tag]

    init(title: String = "Untitled", latexSource: String = "") {
        self.id = UUID()
        self.title = title
        self.latexSource = latexSource
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
    }
}
