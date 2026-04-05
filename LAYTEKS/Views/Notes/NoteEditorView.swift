import SwiftUI
import SwiftData

enum EditorTab { case edit, preview }
enum EditorLayout: String { case tabbed, split }

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.appTheme) var theme
    @Environment(\.modelContext) var context

    @AppStorage("editorLayout")         private var layoutRaw: String = EditorLayout.tabbed.rawValue
    @AppStorage("editorFontSize")       private var editorFontSize: Double = 14
    @AppStorage("autocompleteBrackets") private var autocompleteBrackets: Bool = true
    @AppStorage("livePreview")          private var livePreview: Bool = true
    @AppStorage("showRenderErrors")     private var showRenderErrors: Bool = true

    @State private var selectedTab: EditorTab = .edit
    @State private var showingAddTag = false
    @State private var newTagName = ""
    @State private var showingDeleteConfirm = false
    @Query private var allTags: [Tag]
    @Query private var allFolders: [Folder]

    private var layout: EditorLayout {
        EditorLayout(rawValue: layoutRaw) ?? .tabbed
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                titleField
                if layout == .tabbed {
                    tabbedLayout
                } else {
                    splitLayout
                }
                metaRow
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { editorToolbar }
        .alert("Add Tag", isPresented: $showingAddTag) {
            TextField("tag name", text: $newTagName)
            Button("Add") { addTag() }
            Button("Cancel", role: .cancel) { newTagName = "" }
        }
        .confirmationDialog("Delete Note?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { context.delete(note) }
        }
    }

    // MARK: - Subviews

    private var titleField: some View {
        TextField("Title", text: $note.title)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(theme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .onChange(of: note.title) { _, _ in note.updatedAt = Date() }
    }

    private var tabbedLayout: some View {
        VStack(spacing: 0) {
            tabPicker
            Divider().background(theme.surface)
            tabContent
        }
    }

    private var splitLayout: some View {
        VStack(spacing: 0) {
            LaTeXEditorView(
                text: $note.latexSource,
                theme: theme,
                fontSize: editorFontSize,
                autocomplete: autocompleteBrackets,
                onTextChange: { note.updatedAt = Date() }
            )
            .frame(maxHeight: .infinity)
            .background(theme.surface)

            Divider().background(theme.accent.opacity(0.3))

            if livePreview {
                KaTeXWebView(
                    latexSource: note.latexSource,
                    theme: theme,
                    showErrors: showRenderErrors
                )
                .frame(maxHeight: .infinity)
                .background(theme.background)
            }
        }
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach([EditorTab.edit, .preview], id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
                } label: {
                    Text(tab == .edit ? "Edit" : "Preview")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selectedTab == tab ? theme.background : theme.secondaryText)
                        .background(selectedTab == tab ? theme.accent : Color.clear)
                }
            }
        }
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var tabContent: some View {
        if selectedTab == .edit {
            LaTeXEditorView(
                text: $note.latexSource,
                theme: theme,
                fontSize: editorFontSize,
                autocomplete: autocompleteBrackets,
                onTextChange: { note.updatedAt = Date() }
            )
            .background(theme.surface)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                KaTeXWebView(
                    latexSource: note.latexSource,
                    theme: theme,
                    showErrors: showRenderErrors
                )
                .frame(minHeight: 200)
            }
            .background(theme.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var metaRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let folder = note.folder {
                    TagChipView(label: folder.name, icon: "folder", theme: theme) {
                        note.folder = nil
                    }
                }
                ForEach(note.tags) { tag in
                    TagChipView(label: "#\(tag.name)", icon: nil, theme: theme) {
                        note.tags.removeAll { $0.id == tag.id }
                    }
                }
                Button {
                    showingAddTag = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(theme.surface)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                UIPasteboard.general.string = note.latexSource
            } label: {
                Image(systemName: "doc.on.clipboard")
                    .foregroundStyle(theme.accent)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Move to Folder", systemImage: "folder") {}
                Button("Add Tag", systemImage: "tag") { showingAddTag = true }
                Divider()
                Button("Delete Note", systemImage: "trash", role: .destructive) {
                    showingDeleteConfirm = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(theme.accent)
            }
        }
    }

    // MARK: - Actions

    private func addTag() {
        let trimmed = newTagName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
        guard !trimmed.isEmpty else { newTagName = ""; return }

        if let existing = allTags.first(where: { $0.name == trimmed }) {
            if !note.tags.contains(where: { $0.id == existing.id }) {
                note.tags.append(existing)
            }
        } else {
            let tag = Tag(name: trimmed)
            context.insert(tag)
            note.tags.append(tag)
        }
        newTagName = ""
    }
}

// MARK: - EditorTab: Hashable

extension EditorTab: Hashable {}
