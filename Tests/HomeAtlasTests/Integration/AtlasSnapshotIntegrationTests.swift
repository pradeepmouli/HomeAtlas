import XCTest

#if canImport(HomeKit)
import HomeKit
@testable import HomeAtlas

@MainActor
final class AtlasSnapshotIntegrationTests: XCTestCase {
    @MainActor
    func test_anonymization_is_deterministic() async throws {
        _ = AtlasSnapshotEncoder(options: SnapshotOptions(anonymize: true))
        let a1 = StableAnonymizer.anonymize("Kitchen")
        let a2 = StableAnonymizer.anonymize("Kitchen")
        XCTAssertEqual(a1, a2)
    }
}
#else
@testable import HomeAtlas

final class AtlasSnapshotIntegrationTests: XCTestCase {
    @MainActor
    func test_platform_unavailable() throws {
        let encoder = AtlasSnapshotEncoder(options: SnapshotOptions(anonymize: true))
        XCTAssertNotNil(encoder) // Ensure type is available
    }
}
#endif
