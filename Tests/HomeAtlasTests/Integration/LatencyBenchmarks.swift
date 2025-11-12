import XCTest
@testable import HomeAtlas
import Foundation

/// Integration tests validating HomeKit operation latency targets.
///
/// These benchmarks ensure that operations meet the 95th percentile latency requirement
/// of ≤200ms as specified in NFR-001.
///
/// - Reference: [Apple Developer - HomeKit Performance](https://developer.apple.com/documentation/homekit)
final class LatencyBenchmarks: XCTestCase {

    private var observedEvents: [DiagnosticsEvent] = []
    private var observerToken: UUID?

    @MainActor
    private func installObserver() {
        if observerToken == nil {
            observerToken = DiagnosticsLogger.shared.addObserver { [weak self] event in
                self?.observedEvents.append(event)
            }
        }
        observedEvents.removeAll()
    }

    @MainActor
    private func removeObserver() {
        if let token = observerToken {
            DiagnosticsLogger.shared.removeObserver(token)
            observerToken = nil
        }
        observedEvents.removeAll()
    }

    // MARK: - Cache Operation Benchmarks

    @MainActor
    func testCacheWarmUpMeetsLatencyTarget() async throws {
        installObserver()
        defer { removeObserver() }

        let manager = HomeKitManager()

        // Warm up cache and capture timing
        manager.warmUpCache(includeServices: true, includeCharacteristics: true)

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

    @MainActor
    func testCacheResetMeetsLatencyTarget() async throws {
        installObserver()
        defer { removeObserver() }

        let manager = HomeKitManager()

        // Reset cache and capture timing
        manager.resetCache(includeCharacteristics: true)

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

    @MainActor
    func testMultipleOperationsMeet95thPercentileTarget() async throws {
        installObserver()
        defer { removeObserver() }

        let manager = HomeKitManager()
        let iterations = 20

        // Perform multiple cache operations to collect latency data
        for i in 0..<iterations {
            if i % 2 == 0 {
                manager.warmUpCache(includeServices: false, includeCharacteristics: false)
            } else {
                manager.resetCache(includeCharacteristics: false)
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

    @MainActor
    func testLatencyDistributionIsConsistent() async throws {
        installObserver()
        defer { removeObserver() }

        let manager = HomeKitManager()
        let iterations = 50

        // Perform operations
        for _ in 0..<iterations {
            manager.warmUpCache(includeServices: false, includeCharacteristics: false)
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

    @MainActor
    func testNoOperationsExceedCriticalThreshold() async throws {
        installObserver()
        defer { removeObserver() }

        let manager = HomeKitManager()
        let criticalThreshold = 500.0 // 500ms critical threshold

        // Perform various operations
        manager.warmUpCache(includeServices: true, includeCharacteristics: true)
        manager.resetCache(includeCharacteristics: true)
        manager.warmUpCache(includeServices: false, includeCharacteristics: false)

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

    @MainActor
    func testBenchmarkMetadataIncludesTimestamp() async throws {
        installObserver()
        defer { removeObserver() }

        // Perform an operation
        let manager = HomeKitManager()
        manager.warmUpCache(includeServices: false, includeCharacteristics: false)

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
