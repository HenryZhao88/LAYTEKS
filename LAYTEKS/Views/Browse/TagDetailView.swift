import SwiftUI
import SwiftData

struct TagDetailView: View {
    let tag: Tag
    @Environment(\.appTheme) var theme
    @Environment(\.modelContext) var context
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]

    private var notes: [Note] {
        allNotes.filter { note in note.tags.contains(where: { $0.id == tag.id }) }
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(notes) { note in
                        NavigationLink(value: note) {
                            NoteCard(note: note, theme: theme)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(note)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("#\(tag.name)")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Note.self) { note in
            NoteEditorView(note: note)
        }
    }
}
