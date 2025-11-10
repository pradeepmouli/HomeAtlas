import Foundation

#if canImport(HomeKit)
import HomeKit
#endif

/// A strongly-typed Swift wrapper for Apple HomeKit framework.
///
/// SwiftHomeKit provides compile-time safe abstractions over HomeKit services,
/// characteristics, and accessories with MainActor-bound async APIs.
///
/// Reference: https://developer.apple.com/documentation/homekit
public struct SwiftHomeKit {
    /// Library version
    public static let version = "0.1.0"

    private init() {}
}
