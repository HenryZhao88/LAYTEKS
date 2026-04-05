import SwiftUI
import SwiftData

struct BrowseView: View {
    @Environment(\.appTheme) var theme
    @Environment(\.modelContext) var context
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var showingNewFolder = false
    @State private var newFolderName = ""

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            List {
                if !folders.isEmpty {
                    Section {
                        ForEach(folders) { folder in
                            NavigationLink(destination: FolderDetailView(folder: folder)) {
                                Label {
                                    HStack {
                                        Text(folder.name)
                                            .foregroundStyle(theme.primaryText)
                                        Spacer()
                                        Text("\(folder.notes.count)")
                                            .font(.system(size: 13))
                                            .foregroundStyle(theme.secondaryText)
                                    }
                                } icon: {
                                    Image(systemName: "folder")
                                        .foregroundStyle(theme.accent)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    context.delete(folder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Folders")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.accent)
                            .textCase(nil)
                    }
                }

                if !tags.isEmpty {
                    Section {
                        ForEach(tags) { tag in
                            NavigationLink(destination: TagDetailView(tag: tag)) {
                                Label {
                                    HStack {
                                        Text("#\(tag.name)")
                                            .foregroundStyle(theme.primaryText)
                                        Spacer()
                                        Text("\(tag.notes.count)")
                                            .font(.system(size: 13))
                                            .foregroundStyle(theme.secondaryText)
                                    }
                                } icon: {
                                    Image(systemName: "tag")
                                        .foregroundStyle(theme.accent)
                                }
                            }
                        }
                    } header: {
                        Text("Tags")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.accent)
                            .textCase(nil)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewFolder = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .alert("New Folder", isPresented: $showingNewFolder) {
            TextField("Folder name", text: $newFolderName)
            Button("Create") {
                let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    context.insert(Folder(name: trimmed))
                }
                newFolderName = ""
            }
            Button("Cancel", role: .cancel) { newFolderName = "" }
        }
    }
}
