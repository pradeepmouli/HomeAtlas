// Performance benchmarks for snapshot encoding
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import XCTest
@testable import HomeAtlas
import Foundation

#if canImport(HomeKit)
import HomeKit

@available(iOS 18.0, macOS 15.0, *)
final class SnapshotPerformanceTests: XCTestCase {

    // MARK: - Encoding Performance

    func testEncodingSmallHome() {
        let snapshot = createMockSnapshot(
            rooms: 5,
            accessories: 10,
            servicesPerAccessory: 2,
            characteristicsPerService: 5
        )

        measure {
            _ = try! JSONEncoder().encode(snapshot)
        }
    }

    func testEncodingMediumHome() {
        let snapshot = createMockSnapshot(
            rooms: 20,
            accessories: 50,
            servicesPerAccessory: 3,
            characteristicsPerService: 10
        )

        measure {
            _ = try! JSONEncoder().encode(snapshot)
        }
    }

    func testEncodingLargeHome() {
        // Target: ≤2s for ~100 accessories with ~1000 characteristics
        let snapshot = createMockSnapshot(
            rooms: 30,
            accessories: 100,
            servicesPerAccessory: 2,
            characteristicsPerService: 5
        )

        measure {
            _ = try! JSONEncoder().encode(snapshot)
        }
    }

    // MARK: - Decoding Performance

    func testDecodingSmallHome() {
        let snapshot = createMockSnapshot(rooms: 5, accessories: 10, servicesPerAccessory: 2, characteristicsPerService: 5)
        let data = try! JSONEncoder().encode(snapshot)

        measure {
            _ = try! JSONDecoder().decode(HomeSnapshot.self, from: data)
        }
    }

    func testDecodingLargeHome() {
        let snapshot = createMockSnapshot(rooms: 30, accessories: 100, servicesPerAccessory: 2, characteristicsPerService: 5)
        let data = try! JSONEncoder().encode(snapshot)

        measure {
            _ = try! JSONDecoder().decode(HomeSnapshot.self, from: data)
        }
    }

    // MARK: - Sorting Performance

    func testSortingManyRooms() {
        let rooms = (0..<1000).map {
            RoomSnapshot(
                id: "r-\($0)",
                name: "Room \(Int.random(in: 0..<1000))",
                accessories: []
            )
        }

        measure {
            _ = SnapshotHelpers.sortRooms(rooms)
        }
    }

    func testSortingManyAccessories() {
        let accessories = (0..<1000).map {
            AccessorySnapshot(
                id: "acc-\($0)",
                name: "Accessory \(Int.random(in: 0..<1000))",
                manufacturer: nil,
                model: nil,
                firmwareVersion: nil,
                services: []
            )
        }

        measure {
            _ = SnapshotHelpers.sortAccessories(accessories)
        }
    }

    func testSortingManyCharacteristics() {
        let characteristics = (0..<10000).map {
            CharacteristicSnapshot(
                id: "char-\($0)",
                characteristicType: "type-\(Int.random(in: 0..<100))",
                displayName: nil,
                unit: nil,
                min: nil,
                max: nil,
                step: nil,
                readable: true,
                writable: false,
                value: nil,
                reason: nil
            )
        }

        measure {
            _ = SnapshotHelpers.sortCharacteristics(characteristics)
        }
    }

    // MARK: - Anonymization Performance

    func testAnonymizingSmallHome() {
        // Note: anonymize() method to be implemented in future task
        // Placeholder for performance testing
    }

    func testAnonymizingLargeHome() {
        // Note: anonymize() method to be implemented in future task
        // Placeholder for performance testing
    }

    // MARK: - Memory Performance

    func testMemoryUsageForLargeSnapshot() {
        // This test documents expected memory usage
        // XCTest doesn't have built-in memory measurement, but we can create large structures

        let snapshot = createMockSnapshot(
            rooms: 50,
            accessories: 200,
            servicesPerAccessory: 3,
            characteristicsPerService: 10
        )

        // Encode to measure JSON size
        let data = try! JSONEncoder().encode(snapshot)

        // Document size in comments for tracking
        // Expected: < 5 MB for 200 accessories with ~6000 characteristics
        XCTAssert(data.count < 5_000_000, "JSON size should be under 5 MB")
    }

    // MARK: - End-to-End Performance

    func testFullPipelineSmallHome() {
        // Create → Encode → Decode → Verify
        measure {
            let snapshot = createMockSnapshot(rooms: 5, accessories: 10, servicesPerAccessory: 2, characteristicsPerService: 5)
            let data = try! JSONEncoder().encode(snapshot)
            let decoded = try! JSONDecoder().decode(HomeSnapshot.self, from: data)
            _ = decoded.rooms.count == snapshot.rooms.count
        }
    }

    func testFullPipelineWithAnonymization() {
        // Note: anonymize() method to be implemented in future task
        // Placeholder for full pipeline with anonymization
    }

    // MARK: - Helper Methods

    private func createMockSnapshot(
        rooms: Int,
        accessories: Int,
        servicesPerAccessory: Int,
        characteristicsPerService: Int
    ) -> HomeSnapshot {

        let mockAccessories = (0..<accessories).map { accIndex -> AccessorySnapshot in
            let mockServices = (0..<servicesPerAccessory).map { svcIndex -> ServiceSnapshot in
                let mockCharacteristics = (0..<characteristicsPerService).map { charIndex -> CharacteristicSnapshot in
                    CharacteristicSnapshot(
                        id: "char-\(accIndex)-\(svcIndex)-\(charIndex)",
                        characteristicType: "type-\(charIndex)",
                        displayName: "Char \(charIndex)",
                        unit: "percentage",
                        min: 0,
                        max: 100,
                        step: 1,
                        readable: true,
                        writable: Bool.random(),
                        value: CharacteristicSnapshot.AnyCodable(Int.random(in: 0..<100)),
                        reason: nil
                    )
                }

                return ServiceSnapshot(
                    id: "svc-\(accIndex)-\(svcIndex)",
                    name: "Service \(svcIndex)",
                    serviceType: "lightbulb",
                    characteristics: mockCharacteristics
                )
            }

            return AccessorySnapshot(
                id: "acc-\(accIndex)",
                name: "Accessory \(accIndex)",
                manufacturer: "Mock Inc.",
                model: "Model \(accIndex % 10)",
                firmwareVersion: "1.0.0",
                services: mockServices
            )
        }

        let mockRooms = (0..<rooms).map { roomIndex -> RoomSnapshot in
            let roomAccessories = mockAccessories.filter { _ in Int.random(in: 0..<rooms) == roomIndex }
            return RoomSnapshot(
                id: "room-\(roomIndex)",
                name: "Room \(roomIndex)",
                accessories: Array(roomAccessories.prefix(accessories / rooms))
            )
        }

        let mockZones = (0..<(rooms / 3)).map {
            ZoneSnapshot(
                id: "zone-\($0)",
                name: "Zone \($0)",
                roomIds: Array(mockRooms.prefix(3).map { $0.id })
            )
        }

        return HomeSnapshot(
            id: "home-mock",
            name: "Mock Home",
            rooms: mockRooms,
            zones: mockZones,
            metadata: nil
        )
    }
}

#endif
