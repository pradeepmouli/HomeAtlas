// AUTO-GENERATED DIRECTORY: Sources/HomeAtlas/Encoding/
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import Foundation

#if canImport(HomeKit)
import HomeKit
#endif

/// Main encoder for creating JSON snapshots of HomeKit Home graphs
@MainActor
public final class HomeSnapshotEncoder {

    private let options: SnapshotOptions

    public init(options: SnapshotOptions = SnapshotOptions()) {
        self.options = options
    }

#if canImport(HomeKit)
    /// Encode a Home to its snapshot representation
    /// - Parameter home: The HMHome to snapshot
    /// - Returns: HomeSnapshot with deterministically ordered entities
    /// - Throws: HomeKitError if encoding fails
    public func encode(_ home: HMHome) async throws -> HomeSnapshot {
        do {
            let id = anonymize(home.uniqueIdentifier.uuidString)
            let name = anonymize(home.name)

            // Convert rooms
            var roomSnapshots: [RoomSnapshot] = []
            for room in home.rooms {
                let roomSnapshot = try await encodeRoom(room)
                roomSnapshots.append(roomSnapshot)
            }

            // Convert zones
            var zoneSnapshots: [ZoneSnapshot] = []
            for zone in home.zones {
                let zoneSnapshot = encodeZone(zone)
                zoneSnapshots.append(zoneSnapshot)
            }

            // Apply deterministic ordering
            let sortedRooms = SnapshotHelpers.sortRooms(roomSnapshots)
            let sortedZones = SnapshotHelpers.sortZones(zoneSnapshots)

            return HomeSnapshot(
                id: id,
                name: name,
                rooms: sortedRooms,
                zones: sortedZones,
                metadata: nil // Can be extended with creation/update timestamps
            )
        } catch let error as HomeKitError {
            throw error
        } catch {
            throw HomeKitError.homeManagement(
                operation: .homeUpdate,
                underlying: error
            )
        }
    }

    private func encodeZone(_ zone: HMZone) -> ZoneSnapshot {
        let id = anonymize(zone.uniqueIdentifier.uuidString)
        let name = anonymize(zone.name)
        let roomIds = zone.rooms.map { anonymize($0.uniqueIdentifier.uuidString) }

        return ZoneSnapshot(id: id, name: name, roomIds: roomIds)
    }

    private func encodeRoom(_ room: HMRoom) async throws -> RoomSnapshot {
        let id = anonymize(room.uniqueIdentifier.uuidString)
        let name = anonymize(room.name)

        var accessorySnapshots: [AccessorySnapshot] = []
        for accessory in room.accessories {
            let accessorySnapshot = try await encodeAccessory(accessory)
            accessorySnapshots.append(accessorySnapshot)
        }

        let sortedAccessories = SnapshotHelpers.sortAccessories(accessorySnapshots)

        return RoomSnapshot(id: id, name: name, accessories: sortedAccessories)
    }

    private func encodeAccessory(_ accessory: HMAccessory) async throws -> AccessorySnapshot {
        let id = anonymize(accessory.uniqueIdentifier.uuidString)
        let name = anonymize(accessory.name)
        let manufacturer = accessory.manufacturer.map { anonymize($0) }
        let model = accessory.model.map { anonymize($0) }
        let firmwareVersion = accessory.firmwareVersion

        var serviceSnapshots: [ServiceSnapshot] = []
        for service in accessory.services {
            let serviceSnapshot = try await encodeService(service)
            serviceSnapshots.append(serviceSnapshot)
        }

        let sortedServices = SnapshotHelpers.sortServices(serviceSnapshots)

        return AccessorySnapshot(
            id: id,
            name: name,
            manufacturer: manufacturer,
            model: model,
            firmwareVersion: firmwareVersion,
            services: sortedServices
        )
    }

    private func encodeService(_ service: HMService) async throws -> ServiceSnapshot {
        let id = anonymize(service.uniqueIdentifier.uuidString)
        let name: String? = anonymize(service.name)
        let serviceType = service.serviceType

        var characteristicSnapshots: [CharacteristicSnapshot] = []
        for characteristic in service.characteristics {
            let charSnapshot = try await encodeCharacteristic(characteristic)
            characteristicSnapshots.append(charSnapshot)
        }

        let sortedCharacteristics = SnapshotHelpers.sortCharacteristics(characteristicSnapshots)

        return ServiceSnapshot(
            id: id,
            name: name,
            serviceType: serviceType,
            characteristics: sortedCharacteristics
        )
    }

    private func encodeCharacteristic(_ characteristic: HMCharacteristic) async throws -> CharacteristicSnapshot {
        let id = anonymize(characteristic.uniqueIdentifier.uuidString)
        let characteristicType = characteristic.characteristicType
        let displayName = characteristic.localizedDescription
        let unit = characteristic.metadata?.units?.description
        let min = characteristic.metadata?.minimumValue as? Double
        let max = characteristic.metadata?.maximumValue as? Double
        let step = characteristic.metadata?.stepValue as? Double
        let readable = characteristic.properties.contains(HMCharacteristicPropertyReadable)
        let writable = characteristic.properties.contains(HMCharacteristicPropertyWritable)

        var value: CharacteristicSnapshot.AnyCodable?
        var reason: String?

        // Read value if readable
        if readable {
            // Try to access the value (it's a property, not async)
            let charValue = characteristic.value
            if let charValue = charValue {
                value = CharacteristicSnapshot.AnyCodable(charValue)
            } else {
                value = nil
                reason = "unavailable"
            }
        } else {
            value = nil
            reason = "not-readable"
        }

        return CharacteristicSnapshot(
            id: id,
            characteristicType: characteristicType,
            displayName: displayName,
            unit: unit,
            min: min,
            max: max,
            step: step,
            readable: readable,
            writable: writable,
            value: value,
            reason: reason
        )
    }

    /// Anonymize a string if options.anonymize is true
    private func anonymize(_ string: String) -> String {
        guard options.anonymize else { return string }
        // Use deterministic hashing (FNV-1a) for stability across processes.
        return StableAnonymizer.anonymize(string)
    }
#else
    /// Platform fallback when HomeKit is not available
    public func encode(_ home: Any) async throws -> HomeSnapshot {
        throw HomeKitError.platformUnavailable(
            reason: "HomeKit is not available on this platform"
        )
    }
#endif
}
