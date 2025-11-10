import Foundation

#if canImport(HomeKit)
import HomeKit

/// A strongly-typed wrapper for HMHome.
///
/// Home represents a physical location where HomeKit accessories are installed and managed.
/// It provides access to rooms, zones, accessories, and automation configurations.
///
/// - Reference: [Apple Developer - HMHome](https://developer.apple.com/documentation/homekit/hmhome)
@MainActor
public final class Home {
    private let underlying: HMHome

    /// The name of the home.
    ///
    /// - Reference: [Apple Developer - HMHome name](https://developer.apple.com/documentation/homekit/hmhome/name)
    public var name: String {
        underlying.name
    }

    /// The unique identifier for the home.
    ///
    /// - Reference: [Apple Developer - HMHome uniqueIdentifier](https://developer.apple.com/documentation/homekit/hmhome/uniqueidentifier)
    public var uniqueIdentifier: UUID {
        underlying.uniqueIdentifier
    }

    /// Indicates whether this is the primary home.
    ///
    /// - Reference: [Apple Developer - HMHome isPrimary](https://developer.apple.com/documentation/homekit/hmhome/isprimary)
    public var isPrimary: Bool {
        underlying.isPrimary
    }

    /// The current user's privilege level for this home.
    ///
    /// - Reference: [Apple Developer - HMHome homeAccessControl](https://developer.apple.com/documentation/homekit/hmhome/homeaccesscontrol)
    public var homeAccessControl: HMHomeAccessControl {
        underlying.homeAccessControlForUser()
    }

    /// An array of accessories in the home.
    ///
    /// - Reference: [Apple Developer - HMHome accessories](https://developer.apple.com/documentation/homekit/hmhome/accessories)
    public var accessories: [HMAccessory] {
        underlying.accessories
    }

    /// An array of rooms in the home.
    ///
    /// This property provides access to user-managed rooms, excluding the default room
    /// which represents unassigned accessories.
    ///
    /// - Reference: [Apple Developer - HMHome rooms](https://developer.apple.com/documentation/homekit/hmhome/rooms)
    public var rooms: [HMRoom] {
        underlying.rooms
    }

    /// An array of zones in the home.
    ///
    /// Zones are logical groupings of rooms that allow for coordinated automation scenarios.
    ///
    /// - Reference: [Apple Developer - HMHome zones](https://developer.apple.com/documentation/homekit/hmhome/zones)
    public var zones: [HMZone] {
        underlying.zones
    }

    /// An array of service groups in the home.
    ///
    /// - Reference: [Apple Developer - HMHome serviceGroups](https://developer.apple.com/documentation/homekit/hmhome/servicegroups)
    public var serviceGroups: [HMServiceGroup] {
        underlying.serviceGroups
    }

    /// An array of action sets in the home.
    ///
    /// - Reference: [Apple Developer - HMHome actionSets](https://developer.apple.com/documentation/homekit/hmhome/actionsets)
    public var actionSets: [HMActionSet] {
        underlying.actionSets
    }

    /// An array of triggers in the home.
    ///
    /// - Reference: [Apple Developer - HMHome triggers](https://developer.apple.com/documentation/homekit/hmhome/triggers)
    public var triggers: [HMTrigger] {
        underlying.triggers
    }

    /// The delegate that receives state updates for the home.
    ///
    /// - Reference: [Apple Developer - HMHomeDelegate](https://developer.apple.com/documentation/homekit/hmhomedelegate)
    public var delegate: HMHomeDelegate? {
        get { underlying.delegate }
        set { underlying.delegate = newValue }
    }

    internal init(underlying: HMHome) {
        self.underlying = underlying
    }

    // MARK: - Room Management

    /// Returns the default room representing all parts of the home not assigned to a specific room.
    ///
    /// - Returns: The room for the entire home where unassigned accessories are placed.
    ///
    /// - Reference: [Apple Developer - HMHome roomForEntireHome](https://developer.apple.com/documentation/homekit/hmhome/roomforentirehome)
    public func roomForEntireHome() -> HMRoom {
        underlying.roomForEntireHome()
    }

    /// Updates the name of the home.
    ///
    /// - Parameters:
    ///   - name: The new name for the home.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the update fails.
    ///
    /// - Reference: [Apple Developer - HMHome updateName](https://developer.apple.com/documentation/homekit/hmhome/updatename)
    public func updateName(_ name: String) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.updateName(name)
        }

        recordDiagnostics(operation: .homeUpdate, duration: duration, error: nil)
    }

    /// Adds a room to the home.
    ///
    /// - Parameters:
    ///   - roomName: The name of the room to add.
    ///
    /// - Returns: The newly created room.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the operation fails.
    ///
    /// - Reference: [Apple Developer - HMHome addRoom](https://developer.apple.com/documentation/homekit/hmhome/addroom)
    public func addRoom(named roomName: String) async throws -> HMRoom {
        let clock = ContinuousClock()
        var createdRoom: HMRoom?

        let duration = try await clock.measure {
            createdRoom = try await underlying.addRoom(withName: roomName)
        }

        recordDiagnostics(operation: .homeUpdate, duration: duration, error: nil)
        return createdRoom!
    }

    /// Removes a room from the home.
    ///
    /// - Parameters:
    ///   - room: The room to remove.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the operation fails.
    ///
    /// - Reference: [Apple Developer - HMHome removeRoom](https://developer.apple.com/documentation/homekit/hmhome/removeroom)
    public func removeRoom(_ room: HMRoom) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.removeRoom(room)
        }

        recordDiagnostics(operation: .homeUpdate, duration: duration, error: nil)
    }

    // MARK: - Zone Management

    /// Adds a zone to the home.
    ///
    /// - Parameters:
    ///   - zoneName: The name of the zone to add.
    ///
    /// - Returns: The newly created zone.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the operation fails.
    ///
    /// - Reference: [Apple Developer - HMHome addZone](https://developer.apple.com/documentation/homekit/hmhome/addzone)
    public func addZone(named zoneName: String) async throws -> HMZone {
        let clock = ContinuousClock()
        var createdZone: HMZone?

        let duration = try await clock.measure {
            createdZone = try await underlying.addZone(withName: zoneName)
        }

        recordDiagnostics(operation: .homeUpdate, duration: duration, error: nil)
        return createdZone!
    }

    /// Removes a zone from the home.
    ///
    /// - Parameters:
    ///   - zone: The zone to remove.
    ///
    /// - Throws: `HomeKitError.homeManagement` if the operation fails.
    ///
    /// - Reference: [Apple Developer - HMHome removeZone](https://developer.apple.com/documentation/homekit/hmhome/removezone)
    public func removeZone(_ zone: HMZone) async throws {
        let clock = ContinuousClock()
        let duration = try await clock.measure {
            try await underlying.removeZone(zone)
        }

        recordDiagnostics(operation: .homeUpdate, duration: duration, error: nil)
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
                "homeId": uniqueIdentifier.uuidString,
                "homeName": name
            ]
        )
    }
}

#else

/// Fallback implementation when HomeKit is unavailable.
@MainActor
public final class Home {
    public var name: String { "Unavailable" }
    public var uniqueIdentifier: UUID { UUID() }
    public var isPrimary: Bool { false }

    internal init() {}
}

#endif
