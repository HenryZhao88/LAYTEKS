import SwiftUI

enum FilterChip: Equatable {
    case folder(Folder)
    case tag(Tag)

    static func == (lhs: FilterChip, rhs: FilterChip) -> Bool {
        switch (lhs, rhs) {
        case (.folder(let a), .folder(let b)): return a.id == b.id
        case (.tag(let a),    .tag(let b)):    return a.id == b.id
        default: return false
        }
    }
}

struct FilterChipsView: View {
    let folders: [Folder]
    let tags: [Tag]
    let theme: AppTheme
    @Binding var active: [FilterChip]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "All", isActive: active.isEmpty) {
                    active = []
                }
                ForEach(folders) { folder in
                    let chip = FilterChip.folder(folder)
                    chipButton(label: folder.name, icon: "folder", isActive: active.contains(chip)) {
                        toggle(chip)
                    }
                }
                ForEach(tags) { tag in
                    let chip = FilterChip.tag(tag)
                    chipButton(label: "#\(tag.name)", isActive: active.contains(chip)) {
                        toggle(chip)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func chipButton(
        label: String,
        icon: String? = nil,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .medium))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isActive ? theme.background : theme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isActive ? theme.accent : theme.surface)
            .clipShape(Capsule())
        }
    }

    private func toggle(_ chip: FilterChip) {
        if active.contains(chip) {
            active.removeAll { $0 == chip }
        } else {
            active.append(chip)
        }
    }
}
