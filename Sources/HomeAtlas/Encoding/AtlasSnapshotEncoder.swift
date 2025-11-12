// HomeAtlas typed snapshot encoder bridging HM* graph to *AtlasSnapshot types
// Part of feature 003 (HomeAtlas rebrand and JSON serialization)

import Foundation

#if canImport(HomeKit)
import HomeKit

/// Encoder that produces typed HomeAtlas snapshots using @Snapshotable-generated structs.
@MainActor
public final class AtlasSnapshotEncoder {
    private let options: SnapshotOptions

    public init(options: SnapshotOptions = SnapshotOptions()) {
        self.options = options
    }

    public func encode(_ home: HMHome) async throws -> HomeAtlasSnapshot {
        // Use internal initializer available within module
        let homeWrapper = Home(underlying: home)
        return try await HomeAtlasSnapshot(from: homeWrapper, anonymize: anonymize)
    }

    private func anonymize(_ string: String) -> String {
        guard options.anonymize else { return string }
        return StableAnonymizer.anonymize(string)
    }
}
#else
/// Platform fallback when HomeKit is not available
@MainActor
public final class AtlasSnapshotEncoder {
    public init(options: SnapshotOptions = SnapshotOptions()) {}

    public func encode(_ home: Any) async throws -> Any {
        throw HomeKitError.platformUnavailable(reason: "HomeKit is not available on this platform")
    }
}
#endif
