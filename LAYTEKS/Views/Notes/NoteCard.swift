import SwiftUI

// MARK: - NoteFilter (pure, no SwiftData dependencies — tested in FilterTests)

enum NoteFilter {
    static func apply(notes: [Note], folders: [Folder], tags: [Tag], search: String) -> [Note] {
        var result = notes

        let hasFolder = !folders.isEmpty
        let hasTag    = !tags.isEmpty

        if hasFolder || hasTag {
            result = result.filter { note in
                let matchesFolder = hasFolder && folders.contains(where: { $0.id == note.folder?.id })
                let matchesTag    = hasTag    && tags.contains(where: { t in
                    note.tags.contains(where: { $0.id == t.id })
                })
                return matchesFolder || matchesTag
            }
        }

        if !search.isEmpty {
            result = result.filter { note in
                note.title.localizedCaseInsensitiveContains(search) ||
                note.latexSource.localizedCaseInsensitiveContains(search)
            }
        }

        return result
    }
}

// MARK: - NoteCard

struct NoteCard: View {
    let note: Note
    let theme: AppTheme

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(relativeDate)
                    .font(.system(size: 11))
                    .foregroundStyle(theme.secondaryText)
            }

            if !note.latexSource.isEmpty {
                Text(note.latexSource)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if !note.tags.isEmpty || note.folder != nil {
                HStack(spacing: 6) {
                    if let folder = note.folder {
                        Label(folder.name, systemImage: "folder")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(theme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    ForEach(note.tags.prefix(3)) { tag in
                        Text("#\(tag.name)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(theme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.accent.opacity(0.2), lineWidth: 1)
        )
    }
}
