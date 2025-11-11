import SwiftHomeKit

@main
struct App {
    static func main() {
        // Basic import smoke test to ensure integration via SwiftPM works.
        print("SwiftHomeKit imported successfully. Service type key:", ServiceType.lightbulb)
    }
}
