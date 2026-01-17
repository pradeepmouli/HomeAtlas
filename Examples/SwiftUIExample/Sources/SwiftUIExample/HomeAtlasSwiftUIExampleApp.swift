#if canImport(SwiftUI)
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
#else
// SwiftUI not available on this platform
import Foundation

@main
struct HomeAtlasSwiftUIExampleApp {
    static func main() {
        print(
            """
            SwiftUI is not available on this platform. This example requires SwiftUI.
            
            SwiftUI is supported on Apple platforms such as:
            - iOS 13 or later
            - iPadOS 13 or later
            - macOS 10.15 or later
            - tvOS 13 or later
            - watchOS 6 or later
            
            To run this example, open it in Xcode and choose a SwiftUI-capable Apple device or simulator.
            For more details about SwiftUI availability, see: https://developer.apple.com/xcode/swiftui/
            """
        )
    }
}
#endif
