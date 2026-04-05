# LAYTEKS

LAYTEKS is a focused iOS app for writing, organizing, and previewing LaTeX notes with a native SwiftUI interface and a bundled KaTeX rendering pipeline.

Small side project to help with other AI apps I've built.

## Overview

This project was built as a compact, maintainable iOS codebase with a clear separation between persistence, UI, theming, and rendering. The goal was not just to ship a working LaTeX note editor, but to do it with an architecture that stays understandable as the app grows.

The app stores notes locally with SwiftData, renders LaTeX through KaTeX inside `WKWebView`, and uses a small set of reusable SwiftUI components to keep the interface consistent across notes, browsing, and settings.

## Features

- Create and edit LaTeX notes with a dedicated editor.
- Preview rendered math using a bundled KaTeX renderer.
- Organize notes with folders and tags.
- Search notes by title or LaTeX content.
- Filter notes with folder and tag chips.
- Switch between tabbed and split editor layouts.
- Customize theme, editor preferences, and renderer behavior.
- Work fully offline with local bundled rendering assets.

## Development Focus

This README intentionally focuses on how the app was built.

The project uses a simple but deliberate architecture:

- `SwiftUI` for the app shell, screen composition, and navigation.
- `SwiftData` for local persistence and model relationships.
- `WebKit` for KaTeX-backed LaTeX rendering.
- `XCTest` for model, filtering, and bridge utility coverage.
- `XcodeGen` for project generation through `project.yml`.

Rather than mixing rendering logic directly into SwiftUI views, the app keeps the editor and preview pipeline isolated:

- `LaTeXEditorView` wraps `UITextView` for editor-specific behavior such as monospace text entry and bracket autocomplete.
- `KaTeXWebView` wraps `WKWebView` and handles the JavaScript bridge, theme injection, and render requests.
- The KaTeX distribution is bundled locally so the renderer works without network access.

## Architecture

The codebase is organized by responsibility:

```text
LAYTEKS/
├── Models/         SwiftData models for notes, folders, and tags
├── Theme/          Shared theme definitions and environment wiring
├── Rendering/      KaTeX HTML, JS, CSS, fonts, and WebView bridge
├── Components/     Reusable UI pieces and UIKit wrappers
└── Views/          Screen-level SwiftUI views
```

At runtime, the app flows like this:

1. `LAYTEKSApp` creates a shared SwiftData model container.
2. `ContentView` sets up the three main tabs: Notes, Browse, and Settings.
3. `NoteListView` queries persisted notes, folders, and tags, then applies in-memory filtering for search and chip selection.
4. `NoteEditorView` binds directly to a `Note` model and coordinates editing, preview, metadata, and toolbar actions.
5. `KaTeXWebView` loads the bundled HTML renderer and evaluates JavaScript to render escaped LaTeX source.

## Stack And Tooling

### Core technologies

- Swift 5.10
- SwiftUI
- SwiftData
- WebKit / `WKWebView`
- KaTeX 0.16.11
- XCTest
- XcodeGen

### Project configuration

The repository uses `project.yml` as the source of truth for the Xcode project. This keeps build settings, target configuration, bundled rendering assets, and scheme setup in version control in a cleaner way than editing the project file by hand.

## Rendering Approach

One of the more important implementation choices in this app is the rendering boundary.

Instead of relying on a remote service or a native math layout engine, LAYTEKS bundles KaTeX directly in the app and renders through a local HTML document loaded into `WKWebView`. Swift sends escaped LaTeX strings into the page, the page renders the output, and parse failures can be surfaced back to Swift through a script message handler.

That gives the project a few practical benefits:

- predictable rendering behavior
- no network dependency
- a proven LaTeX rendering engine
- a clean separation between native UI state and rendering internals

## Persistence Model

The app uses three SwiftData models:

- `Note`
- `Folder`
- `Tag`

`Note` is the primary record and owns the actual LaTeX source. Notes can optionally belong to one folder and can have many tags. The current structure is intentionally small and flexible, which makes it easy to query directly from views while the app remains lightweight.

## Testing

The test suite is focused on the most stable and valuable logic in the project:

- model relationship behavior
- note filtering logic
- JavaScript string escaping for the KaTeX bridge

This keeps coverage aligned with the app's most failure-prone non-visual logic without overcomplicating the project with brittle UI tests early on.

## Running The Project

### Requirements

- Xcode
- XcodeGen

### Setup

```bash
xcodegen generate
open LAYTEKS.xcodeproj
```

### Build

```bash
xcodebuild build -scheme LAYTEKS -project LAYTEKS.xcodeproj -destination 'generic/platform=iOS Simulator'
```

## Notes

The app target currently builds successfully from the generated Xcode project. If you want to run the unit test target, make sure the test target configuration includes an `Info.plist` or enables generated Info.plist support in the project settings.