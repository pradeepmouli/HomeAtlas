import Foundation

#if canImport(HomeKit)
import HomeKit

/// A strongly-typed wrapper for HMRoom.
///
/// Room represents a physical room within a home where HomeKit accessories are organized.
/// Rooms provide a logical grouping mechanism for accessories to simplify management and automation.
///
/// - Reference: [Apple Developer - HMRoom](https://developer.apple.com/documentation/homekit/hmroom)
@Snapshotable
@MainActor
public final class Room {
    private let underlying: HMRoom

    /// The name of the room.
    ///
    /// - Reference: [Apple Developer - HMRoom name](https://developer.apple.com/documentation/homekit/hmroom/name)
    public var name: String {
        underlying.name
    }

    /// The unique identifier for the room.
    ///
    /// This UUID is used internally by HomeKit to distinguish rooms.
    ///
    /// - Reference: [Apple Developer - HMRoom uniqueIdentifier](https://developer.apple.com/documentation/homekit/hmroom/uniqueidentifier)
    public var uniqueIdentifier: UUID {
        underlying.uniqueIdentifier
    }

    /// An array of accessories assigned to this room.
    ///
    /// - Reference: [Apple Developer - HMRoom accessories](https://developer.apple.com/documentation/homekit/hmroom/accessories)
    public var accessories: [HMAccessory] {
        underlying.accessories
    }

    /// The underlying HMRoom instance for interoperability.
    public var hmRoom: HMRoom {
        underlying
    }

    internal init(underlying: HMRoom) {
        self.underlying = underlying
    }

    /// Convenience initializer that wraps an HMRoom.
    ///
    /// - Parameter hmRoom: The HMRoom instance to wrap.
    public convenience init(_ hmRoom: HMRoom) {
        self.init(underlying: hmRoom)
    }

    // MARK: - Modification

    /// Updates the name of the room.
    ///
    /// - Parameters:
    ///   - name: The new name for the room.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the update fails.
    ///
    /// - Reference: [Apple Developer - HMRoom updateName](https://developer.apple.com/documentation/homekit/hmroom/updatename)
    public func updateName(_ name: String) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.updateName(name)
        }

        recordDiagnostics(operation: .roomUpdate, duration: duration, error: nil)
    }

    // MARK: - Diagnostics

    private func recordDiagnostics(operation: HomeKitOperation, duration: Duration, error: Error?) {
        let durationInterval = TimeInterval(duration.components.seconds) +
                             TimeInterval(duration.components.attoseconds) / 1_000_000_000_000_000_000.0

        DiagnosticsLogger.shared.record(
            operation: operation,
            context: DiagnosticsContext(),
            duration: durationInterval,
            outcome: error == nil ? .success : .failure,
            metadata: [
                "roomId": uniqueIdentifier.uuidString,
                "roomName": name
            ]
        )
    }
}

// MARK: - AccessoryGroup Protocol Conformance

/// Protocol for types that group HomeKit accessories.
///
/// This protocol provides a unified interface for displaying different groupings
/// such as rooms or custom categories.
///
/// - Reference: [Apple Developer - Interacting with a home automation network](https://developer.apple.com/documentation/homekit/interacting-with-a-home-automation-network)
@MainActor
public protocol AccessoryGroup {
    var name: String { get }
    var accessories: [HMAccessory] { get }
}

extension Room: AccessoryGroup {}

#else

/// Fallback implementation when HomeKit is unavailable.
@MainActor
public final class Room {
    public var name: String { "Unavailable" }
    public var uniqueIdentifier: UUID { UUID() }

    internal init() {}
}

public protocol AccessoryGroup {
    var name: String { get }
}

#endif
