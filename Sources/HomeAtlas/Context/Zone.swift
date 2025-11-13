import Foundation

#if canImport(HomeKit)
import HomeKit

/// A strongly-typed wrapper for HMZone.
///
/// Zone represents a logical grouping of rooms within a home, enabling coordinated
/// automation scenarios across multiple spaces. For example, an "Upstairs" zone might
/// contain bedroom and bathroom rooms for simplified control.
///
/// - Note: The special "room for entire home" (representing unassigned accessories) cannot
///   be added to a zone per HomeKit architecture constraints.
///
/// - Reference: [Apple Developer - HMZone](https://developer.apple.com/documentation/homekit/hmzone)
@Snapshotable
@MainActor
public final class Zone {
    private let underlying: HMZone

    /// The name of the zone.
    ///
    /// - Reference: [Apple Developer - HMZone name](https://developer.apple.com/documentation/homekit/hmzone/name)
    public var name: String {
        underlying.name
    }

    /// The unique identifier for the zone.
    ///
    /// This UUID is used internally by HomeKit to distinguish zones.
    ///
    /// - Reference: [Apple Developer - HMZone uniqueIdentifier](https://developer.apple.com/documentation/homekit/hmzone/uniqueidentifier)
    public var uniqueIdentifier: UUID {
        underlying.uniqueIdentifier
    }

    /// An array of rooms assigned to this zone.
    ///
    /// - Reference: [Apple Developer - HMZone rooms](https://developer.apple.com/documentation/homekit/hmzone/rooms)
    public var rooms: [HMRoom] {
        underlying.rooms
    }

    /// The underlying HMZone instance for interoperability.
    public var hmZone: HMZone {
        underlying
    }

    internal init(underlying: HMZone) {
        self.underlying = underlying
    }

    /// Convenience initializer that wraps an HMZone.
    ///
    /// - Parameter hmZone: The HMZone instance to wrap.
    public convenience init(_ hmZone: HMZone) {
        self.init(underlying: hmZone)
    }

    // MARK: - Modification

    /// Updates the name of the zone.
    ///
    /// - Parameters:
    ///   - name: The new name for the zone.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the update fails.
    ///
    /// - Reference: [Apple Developer - HMZone updateName](https://developer.apple.com/documentation/homekit/hmzone/updatename)
    public func updateName(_ name: String) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.updateName(name)
        }

        recordDiagnostics(operation: .zoneUpdate, duration: duration, error: nil)
    }

    /// Adds a room to the zone.
    ///
    /// - Parameters:
    ///   - room: The room to add to the zone.
    ///
    /// - Throws: `HomeKitError.roomForHomeCannotBeInZone` if attempting to add the special
    ///   "room for entire home", or `HomeKitError.homeManagement` for other failures.
    ///
    /// - Reference: [Apple Developer - HMZone addRoom](https://developer.apple.com/documentation/homekit/hmzone/addroom)
    public func addRoom(_ room: HMRoom) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.addRoom(room)
        }

        recordDiagnostics(operation: .zoneUpdate, duration: duration, error: nil)
    }

    /// Removes a room from the zone.
    ///
    /// - Parameters:
    ///   - room: The room to remove from the zone.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the operation fails.
    ///
    /// - Reference: [Apple Developer - HMZone removeRoom](https://developer.apple.com/documentation/homekit/hmzone/removeroom)
    public func removeRoom(_ room: HMRoom) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.removeRoom(room)
        }

        recordDiagnostics(operation: .zoneUpdate, duration: duration, error: nil)
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
                "zoneId": uniqueIdentifier.uuidString,
                "zoneName": name,
                "roomCount": String(rooms.count)
            ]
        )
    }
}

#else

/// Fallback implementation when HomeKit is unavailable.
@MainActor
public final class Zone {
    public var name: String { "Unavailable" }
    public var uniqueIdentifier: UUID { UUID() }

    internal init() {}
}

#endif
