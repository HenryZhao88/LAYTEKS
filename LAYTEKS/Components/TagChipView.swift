import SwiftUI

struct TagChipView: View {
    let label: String
    let icon: String?
    let theme: AppTheme
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                }
            }
        }
        .foregroundStyle(theme.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(theme.accent.opacity(0.15))
        .clipShape(Capsule())
    }
}
