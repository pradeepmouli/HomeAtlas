// Platform Safety Tests
// Verifies graceful fallback on non-HomeKit platforms

import XCTest

#if canImport(HomeKit)
@testable import HomeAtlas

@MainActor
final class PlatformSafetyTests: XCTestCase {

    func test_homeKitAvailable() {
        // On HomeKit platforms, the library should be fully functional
        XCTAssertNotNil(HomeKitManager.self)
        XCTAssertNotNil(Accessory.self)
        XCTAssertNotNil(Service.self)
    }

    func test_snapshotEncoderAvailable() {
        // Snapshot encoder should be available
        let encoder = AtlasSnapshotEncoder()
        XCTAssertNotNil(encoder)
    }

    func test_snapshotModelsCompile() {
        // Snapshot models should compile and be usable
        let snapshot = HomeSnapshot(
            id: "test",
            name: "Test Home",
            rooms: [],
            zones: [],
            metadata: nil
        )
        XCTAssertEqual(snapshot.name, "Test Home")
    }
}

#else
// Non-HomeKit platform tests
@testable import HomeAtlas

@MainActor
final class PlatformSafetyTests: XCTestCase {

    func test_platformUnavailableError() async {
        // On non-HomeKit platforms, operations should throw platformUnavailable
        let encoder = AtlasSnapshotEncoder()

        do {
            _ = try await encoder.encode("dummy" as Any)
            XCTFail("Should have thrown platformUnavailable error")
        } catch let error as HomeKitError {
            if case .platformUnavailable = error {
                // Expected
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_snapshotModelsAvailableOnAllPlatforms() {
        // Snapshot models should work on all platforms (pure Swift DTOs)
        let snapshot = HomeSnapshot(
            id: "test",
            name: "Test Home",
            rooms: [],
            zones: [],
            metadata: nil
        )
        XCTAssertEqual(snapshot.name, "Test Home")

        // Verify Codable works
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(snapshot))
    }

    func test_stableAnonymizerAvailableOnAllPlatforms() {
        // Stable anonymizer should work on all platforms
        let anon1 = StableAnonymizer.anonymize("TestString")
        let anon2 = StableAnonymizer.anonymize("TestString")

        XCTAssertEqual(anon1, anon2, "Anonymization should be deterministic")
        XCTAssertTrue(anon1.hasPrefix("ANON_"), "Should have ANON prefix")
    }
}
#endif
