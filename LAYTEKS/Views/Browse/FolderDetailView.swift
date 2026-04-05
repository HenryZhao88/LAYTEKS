import SwiftUI
import SwiftData

struct FolderDetailView: View {
    let folder: Folder
    @Environment(\.appTheme) var theme
    @Environment(\.modelContext) var context
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]

    private var notes: [Note] {
        allNotes.filter { $0.folder?.id == folder.id }
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
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Note.self) { note in
            NoteEditorView(note: note)
        }
    }
}
