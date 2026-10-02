import SwiftUI
import WebKit

/// Main WebView screen: header + progress + web content + bottom toolbar.
struct MainWebView: View {
    @StateObject private var store = WebStore()
    @State private var progress = 0.0
    @State private var isLoading = true
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var pageTitle = ""
    @State private var errorMessage: String?
    @State private var showShare = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("পত্রিকা প্রতিদিন")
                    .font(.headline.bold())
                    .foregroundStyle(Color(red: 0.76, green: 0.15, blue: 0.17))
                Spacer()
                if isLoading { ProgressView().scaleEffect(0.8) }
            }
            .padding(.horizontal).padding(.vertical, 8)

            // Progress bar
            if isLoading && progress < 1.0 {
                ProgressView(value: progress)
                    .tint(Color(red: 0.76, green: 0.15, blue: 0.17))
                    .padding(.horizontal)
            }

            ZStack {
                WebViewContainer(
                    webView: store.webView,
                    progress: $progress,
                    isLoading: $isLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    pageTitle: $pageTitle
                ) { msg in
                    // Only show full error if page is blank
                    if store.webView.url == nil { errorMessage = msg }
                }

                if let err = errorMessage, store.webView.url == nil {
                    VStack(spacing: 10) {
                        Image(systemName: "wifi.exclamationmark").font(.largeTitle).foregroundStyle(.secondary)
                        Text(err).foregroundStyle(.secondary)
                        Button("আবার চেষ্টা করুন") {
                            errorMessage = nil
                            store.loadHome()
                        }.buttonStyle(.borderedProminent).tint(Color(red: 0.76, green: 0.15, blue: 0.17))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }

            // Bottom toolbar
            HStack(spacing: 24) {
                Button { store.goBack() } label: { Image(systemName: "chevron.left") }
                    .disabled(!canGoBack)
                Button { store.goForward() } label: { Image(systemName: "chevron.right") }
                    .disabled(!canGoForward)
                Button { store.reload() } label: { Image(systemName: "arrow.clockwise") }
                Button { store.loadHome() } label: { Image(systemName: "house") }
                ShareLink(item: store.webView.url ?? WebConstants.homeURL) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .font(.title3)
            .tint(Color(red: 0.76, green: 0.15, blue: 0.17))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
        }
        .background(Color(.systemBackground))
    }
}

/// Owns WKWebView + pull-to-refresh so it survives SwiftUI redraws.
final class WebStore: ObservableObject {
    let webView: WKWebView

    init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        self.webView = wv
        // Pull to refresh
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(doReload), for: .valueChanged)
        wv.scrollView.refreshControl = rc
        loadHome()
    }

    @objc private func doReload() {
        webView.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.webView.scrollView.refreshControl?.endRefreshing()
        }
    }

    func loadHome() { webView.load(URLRequest(url: WebConstants.homeURL)) }
    func goBack() { if webView.canGoBack { webView.goBack() } }
    func goForward() { if webView.canGoForward { webView.goForward() } }
    func reload() { webView.reload() }
}
