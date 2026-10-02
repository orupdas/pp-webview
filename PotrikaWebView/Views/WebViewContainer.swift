import SwiftUI
import WebKit

/// WKWebView wrapper for SwiftUI with progress + state bindings.
struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView
    @Binding var progress: Double
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var pageTitle: String
    var onError: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        // Progress observer
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.isLoading))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        init(_ parent: WebViewContainer) { self.parent = parent }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard let view = object as? WKWebView else { return }
            Task { @MainActor in
                if keyPath == "estimatedProgress" { parent.progress = view.estimatedProgress }
                if keyPath == "isLoading" { parent.isLoading = view.isLoading }
                parent.canGoBack = view.canGoBack
                parent.canGoForward = view.canGoForward
                parent.pageTitle = view.title ?? ""
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                parent.canGoBack = webView.canGoBack
                parent.canGoForward = webView.canGoForward
                parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in parent.onError("পেজ লোড করা যাচ্ছে না") }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let ns = error as NSError
            // Ignore cancelled loads (e.g. back spam)
            if ns.code == NSURLErrorCancelled { return }
            var msg = "পেজ লোড করা যাচ্ছে না"
            if ns.code == NSURLErrorNotConnectedToInternet { msg = "ইন্টারনেট সংযোগ নেই" }
            else if ns.code == NSURLErrorTimedOut { msg = "সময় শেষ হয়ে গেছে। আবার চেষ্টা করুন" }
            let m = msg
            Task { @MainActor in parent.onError(m) }
        }

        // Keep potrikaprotidin.com inside, open other domains in Safari
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = action.request.url else { decisionHandler(.allow); return }
            if url.scheme == "tel" || url.scheme == "mailto" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
