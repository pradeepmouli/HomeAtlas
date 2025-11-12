// AUTO-GENERATED DIRECTORY: Sources/HomeAtlas/Encoding/
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import Foundation

/// Options for configuring snapshot export behavior
public struct SnapshotOptions: Sendable {
    /// When true, anonymize names and identifiers in the exported snapshot
    public var anonymize: Bool

    public init(anonymize: Bool = false) {
        self.anonymize = anonymize
    }
}
