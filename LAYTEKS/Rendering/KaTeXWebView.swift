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
            context.coordinator.presentLoadError("KaTeX renderer assets are missing from the app bundle.")
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
        var didLoadRenderer = false
        weak var webView: WKWebView?

        init(onError: ((String) -> Void)?) {
            self.onError = onError
        }

        func render() {
            guard let webView, didLoadRenderer else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onError?("")
            }
            let escaped  = pendingSource.escapedForJS()
            let bg       = pendingTheme.backgroundHex
            let text     = pendingTheme.primaryTextHex
            let showErr  = pendingShowErrors ? "true" : "false"
            let js = """
            setTheme('\(bg)', '\(text)');
            renderKaTeX('\(escaped)', { showErrors: \(showErr) });
            """
            webView.evaluateJavaScript(js) { [weak self] _, error in
                guard let error else { return }
                self?.presentLoadError("Failed to render LaTeX preview: \(error.localizedDescription)")
            }
        }

        func presentLoadError(_ message: String) {
            guard let webView else { return }
            didLoadRenderer = false

            let escapedMessage = message
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")

            let html = """
            <!DOCTYPE html>
            <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
              <style>
                body {
                  margin: 0;
                  padding: 20px;
                  background: \(pendingTheme.backgroundHex);
                  color: \(pendingTheme.primaryTextHex);
                  font-family: -apple-system, sans-serif;
                }
                .error-block {
                  color: #FF6B6B;
                  font-size: 13px;
                  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
                  background: rgba(255, 107, 107, 0.1);
                  padding: 10px 14px;
                  border-radius: 8px;
                  border-left: 3px solid #FF6B6B;
                  white-space: pre-wrap;
                  word-break: break-word;
                }
              </style>
            </head>
            <body>
              <div class="error-block">\(escapedMessage)</div>
            </body>
            </html>
            """

            webView.loadHTMLString(html, baseURL: nil)
            DispatchQueue.main.async { [weak self] in
                self?.onError?(message)
            }
        }

        // WKNavigationDelegate — fire render once the HTML has loaded
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            didLoadRenderer = true
            render()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            presentLoadError("Failed to load KaTeX renderer: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            presentLoadError("Failed to load KaTeX renderer: \(error.localizedDescription)")
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let allowedSchemes = ["file", "about", "data"]
            if let scheme = url.scheme?.lowercased(), allowedSchemes.contains(scheme) {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Blocked external navigation to \(url.absoluteString). The preview only uses bundled local assets so it works offline.")
            }
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
