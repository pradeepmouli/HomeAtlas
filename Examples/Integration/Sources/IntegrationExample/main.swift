import HomeAtlas

@main
struct App {
    static func main() {
        // Basic import smoke test to ensure integration via SwiftPM works.
        print("HomeAtlas imported successfully. Service type key:", ServiceType.lightbulb)
    }
}
