// Basic unit tests for snapshot encoding
// Part of HomeAtlas rebrand and JSON serialization feature (003)

import XCTest
@testable import HomeAtlas
import Foundation

#if canImport(HomeKit)
import HomeKit

@available(iOS 18.0, macOS 15.0, *)
final class SnapshotBasicTests: XCTestCase {
    
    func testSnapshotModelsCodable() throws {
        // Test basic Codable conformance for snapshot models
        let characteristic = CharacteristicSnapshot(
            id: "char-1",
            characteristicType: "brightness",
            displayName: "Brightness",
            unit: "%",
            min: 0,
            max: 100,
            step: 1,
            readable: true,
            writable: true,
            value: CharacteristicSnapshot.AnyCodable(75),
            reason: nil
        )
        
        let service = ServiceSnapshot(
            id: "svc-1",
            name: "Light",
            serviceType: "lightbulb",
            characteristics: [characteristic]
        )
        
        let accessory = AccessorySnapshot(
            id: "acc-1",
            name: "Lamp",
            manufacturer: "Acme",
            model: "Smart Bulb",
            firmwareVersion: "1.0",
            services: [service]
        )
        
        let room = RoomSnapshot(
            id: "room-1",
            name: "Living Room",
            accessories: [accessory]
        )
        
        let zone = ZoneSnapshot(
            id: "zone-1",
            name: "Downstairs",
            roomIds: ["room-1"]
        )
        
        let home = HomeSnapshot(
            id: "home-1",
            name: "My Home",
            rooms: [room],
            zones: [zone],
            metadata: nil
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(home)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HomeSnapshot.self, from: data)
        
        XCTAssertEqual(decoded.id, "home-1")
        XCTAssertEqual(decoded.name, "My Home")
        XCTAssertEqual(decoded.rooms.count, 1)
        XCTAssertEqual(decoded.zones.count, 1)
    }
    
    func testAnyCodableTypes() throws {
        // Test AnyCodable with various types
        let testCases: [Any] = [
            42,
            3.14,
            "test",
            true,
            [1, 2, 3]
        ]
        
        for value in testCases {
            let wrapped = CharacteristicSnapshot.AnyCodable(value)
            let characteristic = CharacteristicSnapshot(
                id: "char-test",
                characteristicType: "test",
                displayName: nil,
                unit: nil,
                min: nil,
                max: nil,
                step: nil,
                readable: true,
                writable: false,
                value: wrapped,
                reason: nil
            )
            
            let data = try JSONEncoder().encode(characteristic)
            let decoded = try JSONDecoder().decode(CharacteristicSnapshot.self, from: data)
            XCTAssertNotNil(decoded.value)
        }
    }
    
    func testNullCharacteristicWithReason() throws {
        let characteristic = CharacteristicSnapshot(
            id: "char-restricted",
            characteristicType: "temperature",
            displayName: "Temperature",
            unit: "°C",
            min: nil,
            max: nil,
            step: nil,
            readable: false,
            writable: false,
            value: nil,
            reason: "permission"
        )
        
        let data = try JSONEncoder().encode(characteristic)
        let decoded = try JSONDecoder().decode(CharacteristicSnapshot.self, from: data)
        
        XCTAssertNil(decoded.value)
        XCTAssertEqual(decoded.reason, "permission")
    }
}

#endif
