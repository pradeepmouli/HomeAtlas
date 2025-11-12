// AUTO-GENERATED: Public API for HomeAtlas snapshot export
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import Foundation

#if canImport(HomeKit)
import HomeKit
#endif

extension HomeAtlas {

#if canImport(HomeKit)
    /// Encode a Home to a JSON snapshot with deterministic ordering
    /// - Parameters:
    ///   - home: The HMHome to snapshot
    ///   - options: Configuration options for the snapshot export
    /// - Returns: JSON data representing the Home snapshot
    /// - Throws: HomeKitError if encoding fails
    @MainActor
    public static func encodeSnapshot(
        _ home: HMHome,
        options: SnapshotOptions = SnapshotOptions()
    ) async throws -> Data {
        let encoder = HomeSnapshotEncoder(options: options)
        let snapshot = try await encoder.encode(home)

        // Encode to JSON with sorted keys for deterministic output
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try jsonEncoder.encode(snapshot)
    }
#else
    /// Platform fallback when HomeKit is not available
    @MainActor
    public static func encodeSnapshot(
        _ home: Any,
        options: SnapshotOptions = SnapshotOptions()
    ) async throws -> Data {
        throw HomeKitError.platformUnavailable(
            reason: "HomeKit is not available on this platform"
        )
    }
#endif
}
