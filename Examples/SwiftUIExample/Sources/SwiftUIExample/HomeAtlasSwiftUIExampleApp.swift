import SwiftUI
import HomeAtlas

@main
@MainActor
struct HomeAtlasSwiftUIExampleApp: App {
    @StateObject private var manager = HomeKitManager()
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            ContentView(manager: manager, isReady: isReady)
                .task {
                    await manager.waitUntilReady()
                    // Warm basic accessory cache (services only for performance).
                    manager.warmUpCache(includeServices: true)
                    isReady = true
                }
        }
    }
}
