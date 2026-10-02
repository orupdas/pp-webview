# Potrika WebView App (iOS)

Simple WKWebView wrapper for https://potrikaprotidin.com
- Bundle ID: com.potrikaprotidin.web
- iOS 17+, SwiftUI + WKWebView

Features: Splash, progress bar, pull-to-refresh, back/forward, home, reload, share, Bengali offline error + retry.

## Run
1. Copy `PotrikaWebView/` + `PotrikaWebView.xcodeproj` to Mac
2. Open `.xcodeproj` in Xcode 15+
3. Signing → Team select করুন
4. iPhone Simulator → Cmd+R

Change URL: `PotrikaWebView/Utilities/WebConstants.swift` → `homeURL`

⚠️ Note: Apple often rejects pure WebView apps for App Store unless you add native features (push, bookmarks, offline, native menu). For App Store, native version `PotrikaProtidin/` ব্যবহার করুন।
