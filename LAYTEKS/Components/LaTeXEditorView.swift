import SwiftUI
import UIKit

struct LaTeXEditorView: UIViewRepresentable {
    @Binding var text: String
    var theme: AppTheme
    var fontSize: CGFloat
    var autocomplete: Bool
    var onTextChange: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.spellCheckingType = .no
        tv.smartDashesType = .no
        tv.smartQuotesType = .no
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        applyTheme(to: tv)
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        if tv.text != text {
            tv.text = text
        }
        tv.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        applyTheme(to: tv)
    }

    private func applyTheme(to tv: UITextView) {
        tv.textColor = UIColor(theme.accent)
        tv.tintColor = UIColor(theme.accent) // cursor colour
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: LaTeXEditorView

        init(parent: LaTeXEditorView) {
            self.parent = parent
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            guard parent.autocomplete else { return true }

            let pairs: [String: String] = ["{": "}", "[": "]", "(": ")"]
            guard let closing = pairs[text] else { return true }

            // Insert open+close and position cursor between them
            let current = textView.text ?? ""
            guard let swiftRange = Range(range, in: current) else { return true }
            let newText = current.replacingCharacters(in: swiftRange, with: text + closing)
            textView.text = newText
            parent.text = newText

            let insertOffset = range.location + text.count
            if let pos = textView.position(from: textView.beginningOfDocument, offset: insertOffset) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            parent.onTextChange?()
            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.onTextChange?()
        }
    }
}
