import XCTest
import SwiftData
@testable import LAYTEKS

@MainActor
final class FilterTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var physics: Folder!
    var tagComplex: Tag!
    var noteEuler: Note!
    var noteMaxwell: Note!
    var noteGauss: Note!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Note.self, Folder.self, Tag.self, configurations: config)
        context = ModelContext(container)

        physics = Folder(name: "Physics")
        tagComplex = Tag(name: "complex")
        context.insert(physics)
        context.insert(tagComplex)

        noteEuler = Note(title: "Euler", latexSource: "e^{i\\pi}+1=0")
        noteEuler.folder = physics
        noteEuler.tags = [tagComplex]

        noteMaxwell = Note(title: "Maxwell", latexSource: "\\nabla")
        noteMaxwell.folder = physics

        noteGauss = Note(title: "Gauss", latexSource: "\\int e^{-x^2}")

        context.insert(noteEuler)
        context.insert(noteMaxwell)
        context.insert(noteGauss)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func test_filterByFolder_returnsOnlyFolderNotes() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [physics], tags: [], search: "")
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(where: { $0.id == noteEuler.id }))
        XCTAssertTrue(result.contains(where: { $0.id == noteMaxwell.id }))
    }

    func test_filterByTag_returnsTaggedNotes() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [], tags: [tagComplex], search: "")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, noteEuler.id)
    }

    func test_filterBySearch_matchesTitle() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [], tags: [], search: "euler")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, noteEuler.id)
    }

    func test_filterBySearch_matchesLatex() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [], tags: [], search: "nabla")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, noteMaxwell.id)
    }

    func test_noFilter_returnsAll() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [], tags: [], search: "")
        XCTAssertEqual(result.count, 3)
    }

    func test_unionFilter_folderAndTag() {
        let all = [noteEuler!, noteMaxwell!, noteGauss!]
        let result = NoteFilter.apply(notes: all, folders: [physics], tags: [tagComplex], search: "")
        XCTAssertEqual(result.count, 2)
    }
}
