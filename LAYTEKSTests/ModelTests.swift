import XCTest
import SwiftData
@testable import LAYTEKS

@MainActor
final class ModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Note.self, Folder.self, Tag.self,
            configurations: config
        )
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func test_note_defaultTitle_isUntitled() {
        let note = Note()
        XCTAssertEqual(note.title, "Untitled")
    }

    func test_note_assignedToFolder() {
        let folder = Folder(name: "Physics")
        let note = Note(title: "Maxwell", latexSource: "\\nabla")
        context.insert(folder)
        context.insert(note)
        note.folder = folder
        XCTAssertEqual(note.folder?.name, "Physics")
        XCTAssertTrue(folder.notes.contains(where: { $0.id == note.id }))
    }

    func test_tag_attachedToNote() {
        let note = Note(title: "Euler", latexSource: "e^{i\\pi}")
        let tag = Tag(name: "complex")
        context.insert(note)
        context.insert(tag)
        note.tags.append(tag)
        XCTAssertTrue(note.tags.contains(where: { $0.name == "complex" }))
        XCTAssertTrue(tag.notes.contains(where: { $0.id == note.id }))
    }

    func test_note_updatedAt_changesOnModify() throws {
        let note = Note(title: "Test")
        context.insert(note)
        let original = note.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        note.latexSource = "x^2"
        note.updatedAt = Date()
        XCTAssertGreaterThan(note.updatedAt, original)
    }
}
