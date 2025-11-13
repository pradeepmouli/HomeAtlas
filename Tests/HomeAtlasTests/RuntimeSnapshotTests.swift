import XCTest
@testable import HomeAtlas

final class RuntimeSnapshotTests: XCTestCase {
    #if canImport(HomeKit)
    @MainActor
    func testRuntimeHomeSnapshotIfAvailable() async throws {
        // Initialize manager and wait briefly for HomeKit readiness.
        let manager = HomeKitManager.shared
        // Attempt to wait for readiness; if it throws platform unavailable skip.
        do {
            try await manager.waitUntilReady(timeout: .seconds(5))
        } catch {
            throw XCTSkip("HomeKit not ready: \(error)")
        }

        guard let rawHome = manager.primaryHome else {
            throw XCTSkip("No primary HomeKit home configured on this test device.")
        }
        let homeWrapper = Home(rawHome)

        // Capture snapshot with custom anonymizer to validate closure path executes.
        let snapshot = try await HomeAtlasSnapshot(from: homeWrapper, anonymize: { value in
            // Simple deterministic anonymization: reverse string + length tag
            let reversed = String(value.reversed())
            return "anon:" + reversed + ":len=\(value.count)"
        })

        // Basic shape assertions.
        XCTAssertFalse(snapshot.id.isEmpty)
        XCTAssertTrue(snapshot.name.starts(with: "anon:"), "Expected anonymized name prefix")

        // Room and zone ordering should be deterministic (sorted by name ascending).
        let roomNames = snapshot.rooms.map { $0.name }
        XCTAssertEqual(roomNames, roomNames.sorted(), "Rooms not sorted deterministically")
        let zoneNames = snapshot.zones.map { $0.name }
        XCTAssertEqual(zoneNames, zoneNames.sorted(), "Zones not sorted deterministically")
    }
    #else
    func testRuntimeHomeSnapshotUnavailable() throws {
        throw XCTSkip("HomeKit framework not available on this platform.")
    }
    #endif
}
