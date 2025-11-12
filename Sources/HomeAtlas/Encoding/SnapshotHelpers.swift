// AUTO-GENERATED DIRECTORY: Sources/HomeAtlas/Encoding/
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import Foundation

/// Helpers for deterministic ordering of snapshot entities per research.md
enum SnapshotHelpers {
    /// Sort rooms by name (ascending)
    static func sortRooms(_ rooms: [RoomSnapshot]) -> [RoomSnapshot] {
        rooms.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Sort zones by name (ascending)
    static func sortZones(_ zones: [ZoneSnapshot]) -> [ZoneSnapshot] {
        zones.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Sort accessories by name (ascending)
    static func sortAccessories(_ accessories: [AccessorySnapshot]) -> [AccessorySnapshot] {
        accessories.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Sort services by serviceType (ascending), then name
    static func sortServices(_ services: [ServiceSnapshot]) -> [ServiceSnapshot] {
        services.sorted { lhs, rhs in
            if lhs.serviceType != rhs.serviceType {
                return lhs.serviceType.localizedStandardCompare(rhs.serviceType) == .orderedAscending
            }
            let lhsName = lhs.name ?? ""
            let rhsName = rhs.name ?? ""
            return lhsName.localizedStandardCompare(rhsName) == .orderedAscending
        }
    }

    /// Sort characteristics by characteristicType (ascending)
    static func sortCharacteristics(_ characteristics: [CharacteristicSnapshot]) -> [CharacteristicSnapshot] {
        characteristics.sorted { $0.characteristicType.localizedStandardCompare($1.characteristicType) == .orderedAscending }
    }
}
