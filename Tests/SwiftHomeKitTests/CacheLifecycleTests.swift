import XCTest
@testable import SwiftHomeKit

final class CacheLifecycleTests: XCTestCase {
    @MainActor
    func testStubAccessoryCacheLifecycleEmitsDiagnostics() {
        #if !canImport(HomeKit)
        let accessory = Accessory()
        let logger = DiagnosticsLogger.shared
        let previousThreshold = logger.latencyWarningThreshold
        logger.latencyWarningThreshold = 0
        defer { logger.latencyWarningThreshold = previousThreshold }

        let expectation = expectation(description: "Received warmUp and reset diagnostics")
        expectation.expectedFulfillmentCount = 2

        var receivedOperations: [HomeKitOperation] = []
        let token = logger.addObserver { event in
            receivedOperations.append(event.operation)
            expectation.fulfill()
        }
        defer { logger.removeObserver(token) }

        accessory.warmUpCache(includeCharacteristics: true)
        accessory.resetCache(includeCharacteristics: true)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedOperations.count, 2)
        XCTAssertTrue(receivedOperations.contains(.cacheWarmUp))
        XCTAssertTrue(receivedOperations.contains(.cacheReset))
        #else
        try? XCTSkipIf(true, "Stub-specific test")
        #endif
    }

    @MainActor
    func testStubHomeKitManagerCacheAPIsAreNoop() async {
        #if !canImport(HomeKit)
        let manager = HomeKitManager()
        XCTAssertTrue(manager.isReady)
        XCTAssertEqual(manager.homes.count, 0)

        manager.warmUpCache(includeServices: true, includeCharacteristics: true)
        manager.resetCache(includeCharacteristics: true)

        // Ensure stub manager state remains unchanged after no-op cache calls.
        XCTAssertTrue(manager.isReady)
        XCTAssertEqual(manager.homes.count, 0)
        #else
        try? XCTSkipIf(true, "Stub-specific test")
        #endif
    }
}
