import SwiftUI

@main
struct PotrikaWebViewApp: App {
    @State private var showMain = false
    var body: some Scene {
        WindowGroup {
            if showMain {
                NavigationStack { MainWebView() }
            } else {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(red: 0.76, green: 0.15, blue: 0.17))
                            .frame(width: 96, height: 96)
                        Text("প").font(.system(size: 54, weight: .bold)).foregroundStyle(.white)
                    }
                    Text("পত্রিকা প্রতিদিন").font(.title.bold())
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation { showMain = true }
                    }
                }
            }
        }
    }
}
