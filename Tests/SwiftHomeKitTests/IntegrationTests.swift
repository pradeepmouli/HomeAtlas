import XCTest
@testable import SwiftHomeKit
#if canImport(HomeKit)
import HomeKit
#endif

final class LightbulbControlTests: XCTestCase {
    @MainActor
    func testLightbulbServiceTypeSafety() {
        XCTAssertEqual(LightbulbService.serviceType, ServiceType.lightbulb)
        XCTAssertTrue(LightbulbService.requiredCharacteristicTypes.contains(CharacteristicType.powerState))

        let optional = Set(LightbulbService.optionalCharacteristicTypes)
        XCTAssertTrue(optional.contains(CharacteristicType.brightness))
        XCTAssertTrue(optional.contains(CharacteristicType.saturation))

        let powerStateKeyPath = \LightbulbService.powerState
    _ = powerStateKeyPath as KeyPath<LightbulbService, PowerStateCharacteristic?>

        let saturationKeyPath = \LightbulbService.saturation
    _ = saturationKeyPath as KeyPath<LightbulbService, SaturationCharacteristic?>

#if canImport(HomeKit)
        XCTAssertEqual(ServiceType.lightbulb, HMServiceTypeLightbulb)
#else
        XCTAssertEqual(ServiceType.lightbulb, "HMServiceTypeLightbulb")
#endif
    }

    @MainActor
    func testHomeKitManagerDiscovery() async {
        let manager = HomeKitManager()

        // Wait for initial discovery
        await manager.waitUntilReady()

        XCTAssertTrue(manager.isReady)

        #if canImport(HomeKit)
        // On HomeKit platforms, homes array should be non-nil (may be empty)
        XCTAssertNotNil(manager.homes)
        #else
        // On non-HomeKit platforms, should return empty array
        XCTAssertEqual(manager.homes.count, 0)
        XCTAssertEqual(manager.allAccessories().count, 0)
        XCTAssertNil(manager.primaryHome)
        #endif
    }

    @MainActor
    func testAccessoryLookup() async {
        let manager = HomeKitManager()
        await manager.waitUntilReady()

        let accessory = manager.accessory(named: "Test Lightbulb")

        #if !canImport(HomeKit)
        // Should return nil on non-HomeKit platforms
        XCTAssertNil(accessory)
        #endif
    }
}

final class ThermostatControlTests: XCTestCase {
    @MainActor
    func testThermostatServiceTypeSafety() {
        XCTAssertEqual(ThermostatService.serviceType, ServiceType.thermostat)
        let required = Set(ThermostatService.requiredCharacteristicTypes)
        XCTAssertTrue(required.contains(CharacteristicType.currentTemperature))
        XCTAssertTrue(required.contains(CharacteristicType.targetTemperature))

        let temperatureKeyPath = \ThermostatService.currentTemperature
        _ = temperatureKeyPath as KeyPath<ThermostatService, CurrentTemperatureCharacteristic?>

        let targetTemperatureKeyPath = \ThermostatService.targetTemperature
        _ = targetTemperatureKeyPath as KeyPath<ThermostatService, TargetTemperatureCharacteristic?>
    }
}