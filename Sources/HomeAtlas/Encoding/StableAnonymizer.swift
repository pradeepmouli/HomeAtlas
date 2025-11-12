// AUTO-GENERATED: Stable anonymization helper (HomeAtlas feature 003)
// Provides a deterministic, process-stable hash for anonymizing identifiers/names.
// Avoids using Swift's built-in hashValue (which is seeded per process and non-deterministic).

import Foundation

/// Deterministic hashing utility used for anonymization when `SnapshotOptions.anonymize` is true.
/// Uses 64-bit FNV-1a and returns a fixed-length hexadecimal prefix for brevity.
enum StableAnonymizer {
    /// Produce a deterministic anonymized token for an input string.
    /// - Parameters:
    ///   - input: Original string
    ///   - prefix: Optional prefix (default "ANON") to namespace tokens
    ///   - length: Number of hex characters to keep (must be even and <= 16). Defaults to 12 for compactness.
    static func anonymize(_ input: String, prefix: String = "ANON", length: Int = 12) -> String {
        precondition(length > 0 && length <= 16 && length % 2 == 0, "length must be even and <= 16")
        let hashHex = fnv1a64Hex(input)
        let trimmed = String(hashHex.prefix(length))
        return "\(prefix)_\(trimmed)"
    }

    /// Raw 64-bit FNV-1a hash rendered as 16 hex characters.
    private static func fnv1a64Hex(_ input: String) -> String {
        let prime: UInt64 = 1099511628211
        var hash: UInt64 = 14695981039346656037
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return String(format: "%016llx", hash)
    }
}
