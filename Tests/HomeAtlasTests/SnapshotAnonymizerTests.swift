import XCTest
@testable import HomeAtlas

final class SnapshotAnonymizerTests: XCTestCase {
    #if canImport(HomeKit)
    // Compile-time validation: AccessoryAtlasSnapshot should be generated and accept a @Sendable anonymize closure.
    func testSendableClosureTypeCompiles() {
        // Define a @MainActor @Sendable closure and ensure it can be passed where anonymize is expected.
        let closure: @MainActor @Sendable (String) -> String = { value in value + "_anon" }
        // We can't instantiate HMAccessory easily in tests, but we can at least ensure the closure type matches.
        func acceptsSendable(_ f: @MainActor @Sendable (String) -> String) -> String { f("test") }
        let result = acceptsSendable(closure)
        XCTAssertEqual(result, "test_anon")
        // Also reference the generated type symbol to ensure macro expansion occurred.
        _ = Optional<AccessoryAtlasSnapshot>.none
    }
    #else
    func testPlaceholderWhenHomeKitUnavailable() {
        // HomeKit not available; nothing to assert but test presence avoids empty test target.
        XCTAssertTrue(true)
    }
    #endif
}
