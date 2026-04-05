import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.appTheme) var theme
    @Environment(\.modelContext) var context
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var searchText = ""
    @State private var activeFilters: [FilterChip] = []
    @State private var selectedNote: Note? = nil

    private var activeFolders: [Folder] {
        activeFilters.compactMap { if case .folder(let f) = $0 { return f } else { return nil } }
    }
    private var activeTags: [Tag] {
        activeFilters.compactMap { if case .tag(let t) = $0 { return t } else { return nil } }
    }
    private var filteredNotes: [Note] {
        NoteFilter.apply(notes: notes, folders: activeFolders, tags: activeTags, search: searchText)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                FilterChipsView(folders: folders, tags: tags, theme: theme, active: $activeFilters)
                noteList
            }
        }
        .searchable(text: $searchText, prompt: "Search notes or LaTeX")
        .navigationDestination(item: $selectedNote) { note in
            NoteEditorView(note: note)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("LAYTEKS")
                    .font(.system(size: 28, weight: .black))
                    .kerning(3)
                    .foregroundStyle(theme.primaryText)
                Text("\(notes.count) note\(notes.count == 1 ? "" : "s") · \(folders.count) folder\(folders.count == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
            Button(action: createNote) {
                Label("New", systemImage: "square.and.pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.background)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(theme.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var noteList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredNotes) { note in
                    NoteCard(note: note, theme: theme)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedNote = note }
                        .contextMenu {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                context.delete(note)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                context.delete(note)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    private func createNote() {
        let note = Note()
        context.insert(note)
        selectedNote = note
    }
}
