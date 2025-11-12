// Schema validation and determinism tests for snapshot encoding
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import XCTest
@testable import HomeAtlas

final class SnapshotEncodingTests: XCTestCase {

    func testDeterministicOrderingHelpers() {
        let rooms = [
            RoomSnapshot(id: "room-2", name: "Kitchen", accessories: []),
            RoomSnapshot(id: "room-1", name: "Attic", accessories: []),
            RoomSnapshot(id: "room-3", name: "Bedroom", accessories: [])
        ]
        let sortedRooms = SnapshotHelpers.sortRooms(rooms)
        XCTAssertEqual(sortedRooms.map { $0.name }, ["Attic", "Bedroom", "Kitchen"])

        let accessories = [
            AccessorySnapshot(id: "acc-2", name: "B Light", manufacturer: nil, model: nil, firmwareVersion: nil, services: []),
            AccessorySnapshot(id: "acc-1", name: "A Light", manufacturer: nil, model: nil, firmwareVersion: nil, services: []),
            AccessorySnapshot(id: "acc-3", name: "C Light", manufacturer: nil, model: nil, firmwareVersion: nil, services: [])
        ]
        let sortedAccessories = SnapshotHelpers.sortAccessories(accessories)
        XCTAssertEqual(sortedAccessories.map { $0.name }, ["A Light", "B Light", "C Light"])

        let services = [
            ServiceSnapshot(id: "svc-2", name: "Aux", serviceType: "0002", characteristics: []),
            ServiceSnapshot(id: "svc-3", name: "Primary", serviceType: "0002", characteristics: []),
            ServiceSnapshot(id: "svc-1", name: "Main", serviceType: "0001", characteristics: [])
        ]
        let sortedServices = SnapshotHelpers.sortServices(services)
        XCTAssertEqual(sortedServices.map { $0.id }, ["svc-1", "svc-2", "svc-3"], "Services should order by serviceType then name")

        let characteristics = [
            CharacteristicSnapshot(id: "char-2", characteristicType: "PowerState", displayName: nil, unit: nil, min: nil, max: nil, step: nil, readable: true, writable: false, value: nil, reason: nil),
            CharacteristicSnapshot(id: "char-3", characteristicType: "Temperature", displayName: nil, unit: nil, min: nil, max: nil, step: nil, readable: true, writable: false, value: nil, reason: nil),
            CharacteristicSnapshot(id: "char-1", characteristicType: "Brightness", displayName: nil, unit: nil, min: nil, max: nil, step: nil, readable: true, writable: false, value: nil, reason: nil)
        ]
        let sortedCharacteristics = SnapshotHelpers.sortCharacteristics(characteristics)
        XCTAssertEqual(sortedCharacteristics.map { $0.characteristicType }, ["Brightness", "PowerState", "Temperature"])
    }

    func testHomeSnapshotJSONMatchesExpectedShape() throws {
        let characteristicValue = CharacteristicSnapshot(
            id: "char-1",
            characteristicType: "PowerState",
            displayName: "On/Off",
            unit: nil,
            min: nil,
            max: nil,
            step: nil,
            readable: true,
            writable: true,
            value: CharacteristicSnapshot.AnyCodable(true),
            reason: nil
        )

        let characteristicUnavailable = CharacteristicSnapshot(
            id: "char-2",
            characteristicType: "Brightness",
            displayName: "Brightness",
            unit: "%",
            min: 0,
            max: 100,
            step: 1,
            readable: false,
            writable: true,
            value: nil,
            reason: "not-readable"
        )

        let service = ServiceSnapshot(
            id: "svc-1",
            name: "Lightbulb",
            serviceType: "00000043-0000-1000-8000-0026BB765291",
            characteristics: SnapshotHelpers.sortCharacteristics([characteristicUnavailable, characteristicValue])
        )

        let accessory = AccessorySnapshot(
            id: "acc-1",
            name: "Desk Lamp",
            manufacturer: "HomeAtlas",
            model: "Desk 1",
            firmwareVersion: "1.0.0",
            services: SnapshotHelpers.sortServices([service])
        )

        let room = RoomSnapshot(
            id: "room-1",
            name: "Office",
            accessories: SnapshotHelpers.sortAccessories([accessory])
        )

        let zone = ZoneSnapshot(
            id: "zone-1",
            name: "Work",
            roomIds: [room.id]
        )

        let snapshot = HomeSnapshot(
            id: "home-1",
            name: "Primary Home",
            rooms: SnapshotHelpers.sortRooms([room]),
            zones: SnapshotHelpers.sortZones([zone]),
            metadata: .init(createdAt: "2025-01-01T12:00:00Z", updatedAt: "2025-01-02T09:30:00Z")
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(snapshot)

        // Decode back to verify structure aligns with contract expectations.
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let home = jsonObject as? [String: Any] else {
            XCTFail("Expected dictionary for HomeSnapshot JSON")
            return
        }

        XCTAssertEqual(home["id"] as? String, "home-1")
        XCTAssertEqual(home["name"] as? String, "Primary Home")
        XCTAssertNotNil(home["rooms"], "Rooms array required by schema")
        XCTAssertNotNil(home["zones"], "Zones array required by schema")

        if let roomsArray = home["rooms"] as? [[String: Any]] {
            XCTAssertEqual(roomsArray.count, 1)
            XCTAssertEqual(roomsArray.first?["name"] as? String, "Office")
            if let accessoriesArray = roomsArray.first?["accessories"] as? [[String: Any]] {
                XCTAssertEqual(accessoriesArray.count, 1)
                XCTAssertEqual(accessoriesArray.first?["name"] as? String, "Desk Lamp")
                if let servicesArray = accessoriesArray.first?["services"] as? [[String: Any]] {
                    XCTAssertEqual(servicesArray.count, 1)
                    if let firstService = servicesArray.first {
                        XCTAssertEqual(firstService["serviceType"] as? String, service.serviceType)
                        if let characteristicsArray = firstService["characteristics"] as? [[String: Any]] {
                            XCTAssertEqual(characteristicsArray.count, 2)

                            let ids = characteristicsArray.compactMap { $0["id"] as? String }
                            XCTAssertTrue(ids.contains("char-1"))
                            XCTAssertTrue(ids.contains("char-2"))

                            let valueEntry = characteristicsArray.first { ($0["id"] as? String) == "char-1" }
                            XCTAssertEqual(valueEntry?["value"] as? Bool, true)

                            let restrictedEntry = characteristicsArray.first { ($0["id"] as? String) == "char-2" }
                            XCTAssertNil(restrictedEntry?["value"])
                            XCTAssertEqual(restrictedEntry?["reason"] as? String, "not-readable")
                        } else {
                            XCTFail("Expected characteristics array")
                        }
                    } else {
                        XCTFail("Expected service dictionary")
                    }
                } else {
                    XCTFail("Expected services array")
                }
            } else {
                XCTFail("Expected accessories array")
            }
        } else {
            XCTFail("Expected rooms array")
        }

        if let metadata = home["metadata"] as? [String: Any] {
            XCTAssertEqual(metadata["createdAt"] as? String, "2025-01-01T12:00:00Z")
            XCTAssertEqual(metadata["updatedAt"] as? String, "2025-01-02T09:30:00Z")
        } else {
            XCTFail("Expected metadata dictionary")
        }
    }

    func testStableAnonymizerDeterminism() {
        let first = StableAnonymizer.anonymize("Living Room")
        let second = StableAnonymizer.anonymize("Living Room")
        XCTAssertEqual(first, second, "Anonymizer must be deterministic")
        XCTAssertTrue(first.hasPrefix("ANON_"))
        XCTAssertEqual(first.count, 5 + 12, "Default token should include prefix and 12 hex characters")

        let custom = StableAnonymizer.anonymize("Living Room", prefix: "ROOM", length: 8)
        XCTAssertTrue(custom.hasPrefix("ROOM_"))
        XCTAssertEqual(custom.count, 5 + 8)
        XCTAssertNotEqual(custom, first, "Changing prefix/length should result in distinct tokens")
    }
}
