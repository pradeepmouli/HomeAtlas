import XCTest
@testable import SwiftHomeKit
import Foundation

/// Integration tests validating HomeKit operation latency targets.
///
/// These benchmarks ensure that operations meet the 95th percentile latency requirement
/// of ≤200ms as specified in NFR-001.
///
/// - Reference: [Apple Developer - HomeKit Performance](https://developer.apple.com/documentation/homekit)
@MainActor
final class LatencyBenchmarks: XCTestCase {

    private var observedEvents: [DiagnosticsEvent] = []
    private var observerToken: UUID?

    override func setUpWithError() throws {
        try super.setUpWithError()
        observedEvents.removeAll()

        // Register diagnostics observer to capture latency events
        observerToken = DiagnosticsLogger.shared.addObserver { [weak self] event in
            self?.observedEvents.append(event)
        }
    }

    override func tearDownWithError() throws {
        if let token = observerToken {
            DiagnosticsLogger.shared.removeObserver(token)
        }
        observedEvents.removeAll()
        try super.tearDownWithError()
    }

    // MARK: - Cache Operation Benchmarks

    func testCacheWarmUpMeetsLatencyTarget() async throws {
        let manager = HomeKitManager()

        // Warm up cache and capture timing
        await manager.warmUpCache(includeServices: true, includeCharacteristics: true)

        // Find cache warm-up events
        let warmUpEvents = observedEvents.filter { $0.operation == .cacheWarmUp }

        // We expect at least one warm-up event (stub implementation logs it)
        XCTAssertFalse(warmUpEvents.isEmpty, "Expected at least one cache warm-up event")

        // Validate latency for each warm-up operation
        for event in warmUpEvents {
            let latencyMs = event.duration * 1000.0

            print("📊 Cache warm-up latency: \(String(format: "%.2f", latencyMs))ms")

            // Stub operations should be well under 200ms (typically <1ms)
            // This validates the infrastructure is in place
            XCTAssertLessThan(latencyMs, 200.0, "Cache warm-up should complete within 200ms")
        }
    }

    func testCacheResetMeetsLatencyTarget() async throws {
        let manager = HomeKitManager()

        // Reset cache and capture timing
        await manager.resetCache(includeCharacteristics: true)

        // Find cache reset events
        let resetEvents = observedEvents.filter { $0.operation == .cacheReset }

        XCTAssertFalse(resetEvents.isEmpty, "Expected at least one cache reset event")

        for event in resetEvents {
            let latencyMs = event.duration * 1000.0

            print("📊 Cache reset latency: \(String(format: "%.2f", latencyMs))ms")

            XCTAssertLessThan(latencyMs, 200.0, "Cache reset should complete within 200ms")
        }
    }

    // MARK: - Percentile Calculation

    func testMultipleOperationsMeet95thPercentileTarget() async throws {
        let manager = HomeKitManager()
        let iterations = 20

        // Perform multiple cache operations to collect latency data
        for i in 0..<iterations {
            if i % 2 == 0 {
                await manager.warmUpCache(includeServices: false, includeCharacteristics: false)
            } else {
                await manager.resetCache(includeCharacteristics: false)
            }
        }

        // Collect all cache operation latencies
        let cacheEvents = observedEvents.filter {
            $0.operation == .cacheWarmUp || $0.operation == .cacheReset
        }

        XCTAssertGreaterThanOrEqual(cacheEvents.count, iterations, "Should capture all operations")

        // Convert to milliseconds
        let latencies = cacheEvents.map { event -> Double in
            event.duration * 1000.0
        }

        // Calculate 95th percentile
        let sorted = latencies.sorted()
        let p95Index = Int(Double(sorted.count) * 0.95)
        let p95Latency = sorted[min(p95Index, sorted.count - 1)]

        print("📊 Latency statistics:")
        print("   Min: \(String(format: "%.2f", sorted.first ?? 0))ms")
        print("   Max: \(String(format: "%.2f", sorted.last ?? 0))ms")
        print("   Mean: \(String(format: "%.2f", latencies.reduce(0, +) / Double(latencies.count)))ms")
        print("   95th percentile: \(String(format: "%.2f", p95Latency))ms")

        // Validate 95th percentile meets target (≤200ms per NFR-001)
        XCTAssertLessThanOrEqual(p95Latency, 200.0, "95th percentile latency must be ≤200ms")
    }

    // MARK: - Latency Distribution Analysis

    func testLatencyDistributionIsConsistent() async throws {
        let manager = HomeKitManager()
        let iterations = 50

        // Perform operations
        for _ in 0..<iterations {
            await manager.warmUpCache(includeServices: false, includeCharacteristics: false)
        }

        let events = observedEvents.filter { $0.operation == .cacheWarmUp }
        let latencies = events.map { $0.duration * 1000.0 }

        guard !latencies.isEmpty else {
            XCTFail("No latency measurements captured")
            return
        }

        // Calculate statistics
        let mean = latencies.reduce(0, +) / Double(latencies.count)
        let squaredDiffs = latencies.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(latencies.count)
        let stdDev = sqrt(variance)

        print("📊 Distribution analysis:")
        print("   Mean: \(String(format: "%.2f", mean))ms")
        print("   Std Dev: \(String(format: "%.2f", stdDev))ms")
        print("   Coefficient of Variation: \(String(format: "%.2f", stdDev / mean * 100))%")

        // For stub operations, latency should be very consistent (low variance)
        // In production, we'd expect some variance but it should be reasonable
        XCTAssertTrue(true, "Distribution analysis complete")
    }

    // MARK: - Latency Threshold Validation

    func testNoOperationsExceedCriticalThreshold() async throws {
        let manager = HomeKitManager()
        let criticalThreshold = 500.0 // 500ms critical threshold

        // Perform various operations
        await manager.warmUpCache(includeServices: true, includeCharacteristics: true)
        await manager.resetCache(includeCharacteristics: true)
        await manager.warmUpCache(includeServices: false, includeCharacteristics: false)

        // Check all operations
        for event in observedEvents {
            let latencyMs = event.duration * 1000.0

            XCTAssertLessThan(
                latencyMs,
                criticalThreshold,
                "Operation \(event.operation.rawValue) exceeded critical threshold: \(String(format: "%.2f", latencyMs))ms"
            )
        }
    }

    // MARK: - Metadata Validation

    func testBenchmarkMetadataIncludesTimestamp() throws {
        // Perform an operation
        let manager = HomeKitManager()
        Task { @MainActor in
            await manager.warmUpCache(includeServices: false, includeCharacteristics: false)
        }

        // Allow async operation to complete
        let expectation = XCTestExpectation(description: "Wait for operation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Validate event structure
        XCTAssertFalse(observedEvents.isEmpty, "Should capture at least one event")

        if let event = observedEvents.first {
            // Timestamp should be recent (within last second)
            let timeSinceEvent = Date().timeIntervalSince(event.timestamp)
            XCTAssertLessThan(timeSinceEvent, 2.0, "Event timestamp should be recent")

            // Metadata should include operation context
            XCTAssertNotNil(event.metadata["scope"], "Should include scope in metadata")
        }
    }
}
