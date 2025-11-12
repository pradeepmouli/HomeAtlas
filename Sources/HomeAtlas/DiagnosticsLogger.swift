import Foundation
#if canImport(OSLog)
import OSLog
#endif

/// Represents a diagnostics event emitted by HomeAtlas operations.
public struct DiagnosticsEvent: Sendable {
    public enum Outcome: Sendable {
        case success
        case failure
    }

    public let operation: HomeKitOperation
    public let context: DiagnosticsContext
    public let duration: TimeInterval
    public let timestamp: Date
    public let outcome: Outcome
    public let metadata: [String: String]

    public init(
        operation: HomeKitOperation,
        context: DiagnosticsContext,
        duration: TimeInterval,
        timestamp: Date = Date(),
        outcome: Outcome,
        metadata: [String: String]
    ) {
        self.operation = operation
        self.context = context
        self.duration = duration
        self.timestamp = timestamp
        self.outcome = outcome
        self.metadata = metadata
    }
}

/// Central logging facility emitting latency and failure diagnostics for HomeKit interactions.
@MainActor
public final class DiagnosticsLogger: @unchecked Sendable {
    public static let shared = DiagnosticsLogger()

    /// Threshold (in seconds) after which slow operations emit a warning-level log. Defaults to 0.5s.
    public var latencyWarningThreshold: TimeInterval = 0.5

    private let lock = NSLock()
    private var observers: [UUID: (DiagnosticsEvent) -> Void] = [:]

    #if canImport(OSLog)
    private let logger = Logger(subsystem: "com.pradeepmouli.HomeAtlas", category: "Diagnostics")
    #endif

    private init() {}

    /// Registers an observer to receive diagnostics events.
    @discardableResult
    public func addObserver(_ observer: @escaping (DiagnosticsEvent) -> Void) -> UUID {
        let token = UUID()
        lock.lock()
        observers[token] = observer
        lock.unlock()
        return token
    }

    /// Removes a previously registered observer.
    public func removeObserver(_ token: UUID) {
        lock.lock()
        observers.removeValue(forKey: token)
        lock.unlock()
    }

    /// Emits a diagnostics event to OSLog (when available) and registered observers.
    public func record(
        operation: HomeKitOperation,
        context: DiagnosticsContext,
        duration: TimeInterval,
        outcome: DiagnosticsEvent.Outcome,
        metadata: [String: String] = [:]
    ) {
        let event = DiagnosticsEvent(
            operation: operation,
            context: context,
            duration: duration,
            outcome: outcome,
            metadata: metadata
        )

        log(event)
        broadcast(event)
    }

    private func broadcast(_ event: DiagnosticsEvent) {
        lock.lock()
        let sinks = Array(observers.values)
        lock.unlock()

        for sink in sinks {
            sink(event)
        }
    }

    private func log(_ event: DiagnosticsEvent) {
        #if canImport(OSLog)
        let durationString = String(format: "%.3f", event.duration)
        switch event.outcome {
        case .success:
            if event.duration >= latencyWarningThreshold {
                logger.warning("Operation \(event.operation.rawValue, privacy: .public) exceeded latency threshold (\(durationString, privacy: .public)) s")
            }
        case .failure:
            let underlying = event.metadata["underlying"] ?? "unknown error"
            if event.duration >= latencyWarningThreshold {
                logger.error("Operation \(event.operation.rawValue, privacy: .public) failed after \(durationString, privacy: .public) s :: \(underlying, privacy: .public)")
            } else {
                logger.error("Operation \(event.operation.rawValue, privacy: .public) failed :: \(underlying, privacy: .public)")
            }
        }
        #else
        if event.outcome == .failure || event.duration >= latencyWarningThreshold {
            let duration = String(format: "%.3f", event.duration)
            print("[HomeAtlas] \(event.operation.rawValue) :: \(event.outcome) :: \(duration)s :: \(event.metadata)")
        }
        #endif
    }
}
