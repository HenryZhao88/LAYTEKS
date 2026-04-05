import SwiftUI
import WebKit

struct SettingsView: View {
    @Environment(\.appTheme) var theme
    @AppStorage("selectedTheme")        private var selectedThemeRaw: String = AppTheme.deepDark.rawValue
    @AppStorage("editorFontSize")       private var editorFontSize: Double = 14
    @AppStorage("previewFontSize")      private var previewFontSize: Double = 16
    @AppStorage("editorLayout")         private var editorLayoutRaw: String = EditorLayout.tabbed.rawValue
    @AppStorage("livePreview")          private var livePreview: Bool = true
    @AppStorage("autocompleteBrackets") private var autocompleteBrackets: Bool = true
    @AppStorage("showRenderErrors")     private var showRenderErrors: Bool = true
    @AppStorage("renderDebugLog")       private var renderDebugLog: Bool = false

    @State private var showClearCacheConfirm = false

    private let katexVersion = "0.16.11"

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            List {
                appearanceSection
                editorSection
                developerSection
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Clear KaTeX cache?",
            isPresented: $showClearCacheConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear Cache", role: .destructive) {
                WKWebsiteDataStore.default().removeData(
                    ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                    modifiedSince: Date(timeIntervalSince1970: 0)
                ) {}
            }
        } message: {
            Text("This will clear cached WebView data. The renderer will reload on next use.")
        }
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $selectedThemeRaw) {
                ForEach(AppTheme.allCases) { t in
                    Text(t.rawValue).tag(t.rawValue)
                }
            }
            .foregroundStyle(theme.primaryText)

            HStack {
                Text("Editor Font Size")
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Stepper("\(Int(editorFontSize))pt", value: $editorFontSize, in: 12...24, step: 1)
                    .foregroundStyle(theme.primaryText)
            }

            HStack {
                Text("Preview Font Size")
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Stepper("\(Int(previewFontSize))pt", value: $previewFontSize, in: 12...24, step: 1)
                    .foregroundStyle(theme.primaryText)
            }
        } header: {
            Text("Appearance")
                .foregroundStyle(theme.accent)
                .textCase(nil)
        }
        .listRowBackground(theme.surface)
    }

    private var editorSection: some View {
        Section {
            Picker("Layout", selection: $editorLayoutRaw) {
                Text("Tabbed").tag(EditorLayout.tabbed.rawValue)
                Text("Split View").tag(EditorLayout.split.rawValue)
            }
            .foregroundStyle(theme.primaryText)

            if editorLayoutRaw == EditorLayout.split.rawValue {
                Toggle("Live Preview", isOn: $livePreview)
                    .foregroundStyle(theme.primaryText)
                    .tint(theme.accent)
            }

            Toggle("Autocomplete Brackets", isOn: $autocompleteBrackets)
                .foregroundStyle(theme.primaryText)
                .tint(theme.accent)
        } header: {
            Text("Editor")
                .foregroundStyle(theme.accent)
                .textCase(nil)
        }
        .listRowBackground(theme.surface)
    }

    private var developerSection: some View {
        Section {
            HStack {
                Text("KaTeX Version")
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text(katexVersion)
                    .foregroundStyle(theme.secondaryText)
                    .font(.system(size: 14, design: .monospaced))
            }

            Toggle("Show Render Errors Inline", isOn: $showRenderErrors)
                .foregroundStyle(theme.primaryText)
                .tint(theme.accent)

            Toggle("Render Debug Log", isOn: $renderDebugLog)
                .foregroundStyle(theme.primaryText)
                .tint(theme.accent)

            Button {
                showClearCacheConfirm = true
            } label: {
                Label("Clear KaTeX Cache", systemImage: "trash")
                    .foregroundStyle(Color.red)
            }
        } header: {
            Text("Developer")
                .foregroundStyle(theme.accent)
                .textCase(nil)
        }
        .listRowBackground(theme.surface)
    }
}
