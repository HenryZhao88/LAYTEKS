import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.deepDark.rawValue

    private var theme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .deepDark
    }

    var body: some View {
        TabView {
            NavigationStack {
                NoteListView()
            }
            .tabItem {
                Label("Notes", systemImage: "doc.text")
            }

            NavigationStack {
                BrowseView()
            }
            .tabItem {
                Label("Browse", systemImage: "folder")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(theme.accent)
        .environment(\.appTheme, theme)
        .preferredColorScheme(theme.colorScheme)
    }
}
