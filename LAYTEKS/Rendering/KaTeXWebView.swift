import SwiftUI
import WebKit

// MARK: - String escape helper (also tested in KaTeXEscapeTests)

extension String {
    func escapedForJS() -> String {
        self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'",  with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }
}

// MARK: - KaTeXWebView

struct KaTeXWebView: UIViewRepresentable {
    let latexSource: String
    let theme: AppTheme
    var showErrors: Bool = true
    var onError: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onError: onError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "katexError")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = true
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView

        guard let htmlURL = Bundle.main.url(forResource: "katex-render", withExtension: "html") else {
            return webView
        }
        let bundleDir = htmlURL.deletingLastPathComponent()
        webView.loadFileURL(htmlURL, allowingReadAccessTo: bundleDir)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingSource    = latexSource
        context.coordinator.pendingTheme     = theme
        context.coordinator.pendingShowErrors = showErrors
        context.coordinator.onError          = onError
        if !webView.isLoading {
            context.coordinator.render()
        }
    }

    // MARK: Coordinator

    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var onError: ((String) -> Void)?
        var pendingSource: String     = ""
        var pendingTheme: AppTheme    = .deepDark
        var pendingShowErrors: Bool   = true
        weak var webView: WKWebView?

        init(onError: ((String) -> Void)?) {
            self.onError = onError
        }

        func render() {
            guard let webView else { return }
            let escaped  = pendingSource.escapedForJS()
            let bg       = pendingTheme.backgroundHex
            let text     = pendingTheme.primaryTextHex
            let showErr  = pendingShowErrors ? "true" : "false"
            let js = """
            setTheme('\(bg)', '\(text)');
            renderKaTeX('\(escaped)', { showErrors: \(showErr) });
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        // WKNavigationDelegate — fire render once the HTML has loaded
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            render()
        }

        // WKScriptMessageHandler — receive parse errors from JS
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "katexError",
                  let errorMsg = message.body as? String else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onError?(errorMsg)
            }
        }
    }
}
