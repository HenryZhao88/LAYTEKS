import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case deepDark    = "Deep Dark"
    case cleanLight  = "Clean Light"
    case oceanDark   = "Ocean Dark"
    case systemDefault = "System Default"

    var id: String { rawValue }

    var background: Color {
        switch self {
        case .deepDark:       return Color(hex: "0A0A12")
        case .cleanLight:     return Color(hex: "F5F5F0")
        case .oceanDark:      return Color(hex: "0F1923")
        case .systemDefault:  return Color(.systemBackground)
        }
    }

    var surface: Color {
        switch self {
        case .deepDark:       return Color(hex: "13131F")
        case .cleanLight:     return Color(hex: "FFFFFF")
        case .oceanDark:      return Color(hex: "162330")
        case .systemDefault:  return Color(.secondarySystemBackground)
        }
    }

    var accent: Color {
        switch self {
        case .deepDark:       return Color(hex: "7C6FFF")
        case .cleanLight:     return Color(hex: "D63031")
        case .oceanDark:      return Color(hex: "00CEC9")
        case .systemDefault:  return Color.accentColor
        }
    }

    var primaryText: Color {
        switch self {
        case .deepDark:       return Color(hex: "E0E0FF")
        case .cleanLight:     return Color(hex: "1A1A1A")
        case .oceanDark:      return Color(hex: "E8F4F8")
        case .systemDefault:  return Color(.label)
        }
    }

    var secondaryText: Color {
        switch self {
        case .deepDark:       return Color(hex: "555577")
        case .cleanLight:     return Color(hex: "999999")
        case .oceanDark:      return Color(hex: "4A6274")
        case .systemDefault:  return Color(.secondaryLabel)
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .deepDark, .oceanDark: return .dark
        case .cleanLight:           return .light
        case .systemDefault:        return nil
        }
    }

    // Hex strings for injecting into the KaTeX WebView via JS
    var backgroundHex: String {
        switch self {
        case .deepDark:       return "#0A0A12"
        case .cleanLight:     return "#F5F5F0"
        case .oceanDark:      return "#0F1923"
        case .systemDefault:  return "#000000"
        }
    }

    var primaryTextHex: String {
        switch self {
        case .deepDark:       return "#E0E0FF"
        case .cleanLight:     return "#1A1A1A"
        case .oceanDark:      return "#E8F4F8"
        case .systemDefault:  return "#000000"
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
