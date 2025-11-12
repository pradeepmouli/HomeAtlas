import XCTest
@testable import HomeAtlas

final class CharacteristicTests: XCTestCase {
    @MainActor
    func testCharacteristicStubBehavior() async {
        #if !canImport(HomeKit)
        let characteristic = Characteristic<Bool>()

        XCTAssertEqual(characteristic.characteristicType, "")
        XCTAssertEqual(characteristic.localizedDescription, "")
        XCTAssertFalse(characteristic.supportsRead)
        XCTAssertFalse(characteristic.supportsWrite)
        XCTAssertFalse(characteristic.supportsEventNotification)

        do {
            _ = try await characteristic.read()
            XCTFail("Expected error")
        } catch HomeKitError.platformUnavailable {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        #endif
    }
}

final class ServiceTests: XCTestCase {
    @MainActor
    func testServiceStubBehavior() {
        #if !canImport(HomeKit)
        let service = Service()

        XCTAssertEqual(service.serviceType, "")
        XCTAssertNil(service.name)
        XCTAssertFalse(service.isPrimaryService)
        XCTAssertFalse(service.isUserInteractive)

        let characteristic: Characteristic<Bool>? = service.characteristic(ofType: "test")
        XCTAssertNil(characteristic)
        XCTAssertEqual(service.allCharacteristics().count, 0)
        #endif
    }
}

final class AccessoryTests: XCTestCase {
    @MainActor
    func testAccessoryStubBehavior() async {
        #if !canImport(HomeKit)
        let accessory = Accessory()

        XCTAssertEqual(accessory.name, "")
        XCTAssertFalse(accessory.isReachable)
        XCTAssertFalse(accessory.isBlocked)
        XCTAssertFalse(accessory.supportsIdentify)

        XCTAssertNil(accessory.service(ofType: "test"))
        XCTAssertEqual(accessory.allServices().count, 0)

        do {
            try await accessory.identify()
            XCTFail("Expected error")
        } catch HomeKitError.platformUnavailable {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        #endif
    }
}
