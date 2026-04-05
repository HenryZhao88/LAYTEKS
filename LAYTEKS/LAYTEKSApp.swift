import SwiftUI
import SwiftData

@main
struct LAYTEKSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Note.self, Folder.self, Tag.self])
    }
}
