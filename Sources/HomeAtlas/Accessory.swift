import Foundation

#if canImport(HomeKit)
import HomeKit

/// A strongly-typed wrapper for HMAccessory.
///
/// Accessory represents a HomeKit accessory and provides access to its services
/// and metadata.
///
/// Reference: https://developer.apple.com/documentation/homekit/hmaccessory
@Snapshotable
@MainActor
public final class Accessory: HomeKitDescribable {
    private let underlying: HMAccessory
    private var serviceCache: [UUID: AnyObject] = [:]

    /// The name of the accessory.
    public var name: String {
        underlying.name
    }

    /// The unique identifier for the accessory.
    public var uniqueIdentifier: UUID {
        underlying.uniqueIdentifier
    }

    /// A localized description of the accessory category.
    public var localizedDescription: String {
        underlying.category.localizedDescription
    }

    /// Indicates whether the accessory is reachable.
    public var isReachable: Bool {
        underlying.isReachable
    }

    /// Indicates whether the accessory is blocked.
    public var isBlocked: Bool {
        underlying.isBlocked
    }

    /// The room that contains this accessory.
    public var room: HMRoom? {
        underlying.room
    }

    /// The category of the accessory.
    public var category: HMAccessoryCategory {
        underlying.category
    }

    /// Indicates whether the bridge supports identifying the accessory.
    public var supportsIdentify: Bool {
        underlying.supportsIdentify
    }

    internal init(underlying: HMAccessory) {
        self.underlying = underlying
    }

    /// Convenience initializer that wraps an HMAccessory.
    ///
    /// - Parameter hmAccessory: The HMAccessory instance to wrap.
    public convenience init(_ hmAccessory: HMAccessory) {
        self.init(underlying: hmAccessory)
    }

    /// Returns a service of the specified type.
    ///
    /// - Parameter serviceType: The service type identifier.
    /// - Returns: A Service wrapper, or nil if not found.
    public func service(ofType serviceType: String) -> Service? {
        guard let hmService = underlying.services.first(where: { $0.serviceType == serviceType }) else {
            return nil
        }
        return cachedService(for: hmService)
    }

    /// Returns the first generated service wrapper of the given type, if present.
    public func service<T: GeneratedService>(of type: T.Type) -> T? {
        guard let hmService = underlying.services.first(where: { $0.serviceType == type.serviceType }) else {
            return nil
        }
        return cachedService(for: hmService, as: type)
    }

    /// Returns all generated service wrappers of the given type.
    public func services<T: GeneratedService>(of type: T.Type) -> [T] {
        underlying.services
            .filter { $0.serviceType == type.serviceType }
            .map { cachedService(for: $0, as: type) }
    }

    /// Returns all services provided by the accessory.
    ///
    /// - Returns: An array of Service wrappers.
    public func allServices() -> [Service] {
        underlying.services.map { cachedService(for: $0) }
    }

    /// Prepares service wrappers (and optionally characteristic caches) to avoid on-demand instantiation costs.
    ///
    /// - Parameter includeCharacteristics: When true, invokes `warmUpCharacteristicCache()` on every cached service.
    public func warmUpCache(includeCharacteristics: Bool = false) {
        let clock = ContinuousClock()
        let start = clock.now

        let services = underlying.services.map { cachedService(for: $0) }
        if includeCharacteristics {
            services.forEach { $0.warmUpCharacteristicCache() }
        }

        let duration = start.duration(to: clock.now).hkTimeInterval
        DiagnosticsLogger.shared.record(
            operation: .cacheWarmUp,
            context: DiagnosticsContext(AccessoryContext(accessory: underlying)),
            duration: duration,
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "accessory+characteristics" : "accessory",
                "services.count": String(services.count)
            ]
        )
    }

    /// Clears cached service and characteristic wrappers, logging the reset for diagnostics.
    ///
    /// - Parameter includeCharacteristics: When true, clears characteristic caches on each cached service before removal.
    public func resetCache(includeCharacteristics: Bool = false) {
        let removedIdentifiers = serviceCache.keys.map { $0.uuidString }
        if includeCharacteristics {
            serviceCache.values.compactMap { $0 as? Service }.forEach { $0.resetCharacteristicCache() }
        }

        serviceCache.removeAll()

        DiagnosticsLogger.shared.record(
            operation: .cacheReset,
            context: DiagnosticsContext(AccessoryContext(accessory: underlying)),
            duration: 0,
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "accessory+characteristics" : "accessory",
                "services.removed": String(removedIdentifiers.count),
                "services.identifiers": removedIdentifiers.joined(separator: ",")
            ]
        )
    }

    private func cachedService(for hmService: HMService) -> Service {
        let key = hmService.uniqueIdentifier

        if let cached = serviceCache[key] as? Service {
            return cached
        }

        let wrapper = Service(underlying: hmService)
        serviceCache[key] = wrapper
        return wrapper
    }

    private func cachedService<T: GeneratedService>(for hmService: HMService, as type: T.Type) -> T {
        let key = hmService.uniqueIdentifier

        if let cached = serviceCache[key] as? T {
            return cached
        }

        let wrapper = T(underlying: hmService)
        serviceCache[key] = wrapper as AnyObject
        return wrapper
    }

    /// Identifies the accessory (e.g., blinks its LED).
    ///
    /// - Throws: An error if the identify operation fails.
    public func identify() async throws {
        let clock = ContinuousClock()
        let start = clock.now
        let context = AccessoryContext(accessory: underlying)

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                underlying.identify { error in
                    if let error {
                        continuation.resume(throwing: HomeKitError.accessoryOperationFailed(
                            operation: .accessoryIdentify,
                            context: context,
                            underlying: error
                        ))
                    } else {
                        continuation.resume()
                    }
                }
            }

            recordDiagnostics(
                for: .accessoryIdentify,
                context: context,
                clock: clock,
                start: start,
                outcome: .success
            )
        } catch let homeKitError as HomeKitError {
            recordDiagnostics(
                for: .accessoryIdentify,
                context: context,
                clock: clock,
                start: start,
                outcome: .failure,
                error: homeKitError
            )
            throw homeKitError
        } catch {
            let wrapped = HomeKitError.accessoryOperationFailed(
                operation: .accessoryIdentify,
                context: context,
                underlying: error
            )
            recordDiagnostics(
                for: .accessoryIdentify,
                context: context,
                clock: clock,
                start: start,
                outcome: .failure,
                error: wrapped
            )
            throw wrapped
        }
    }

    /// Updates the name of the accessory.
    ///
    /// - Parameter name: The new name for the accessory.
    /// - Throws: An error if the update fails.
    public func updateName(_ name: String) async throws {
        let clock = ContinuousClock()
        let start = clock.now
        let context = AccessoryContext(accessory: underlying)

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                underlying.updateName(name) { error in
                    if let error {
                        continuation.resume(throwing: HomeKitError.accessoryOperationFailed(
                            operation: .accessoryUpdateName,
                            context: context,
                            underlying: error
                        ))
                    } else {
                        continuation.resume()
                    }
                }
            }

            recordDiagnostics(
                for: .accessoryUpdateName,
                context: context,
                clock: clock,
                start: start,
                outcome: .success
            )
        } catch let homeKitError as HomeKitError {
            recordDiagnostics(
                for: .accessoryUpdateName,
                context: context,
                clock: clock,
                start: start,
                outcome: .failure,
                error: homeKitError
            )
            throw homeKitError
        } catch {
            let wrapped = HomeKitError.accessoryOperationFailed(
                operation: .accessoryUpdateName,
                context: context,
                underlying: error
            )
            recordDiagnostics(
                for: .accessoryUpdateName,
                context: context,
                clock: clock,
                start: start,
                outcome: .failure,
                error: wrapped
            )
            throw wrapped
        }
    }
}

private extension Accessory {
    func recordDiagnostics(
        for operation: HomeKitOperation,
        context: AccessoryContext,
        clock: ContinuousClock,
        start: ContinuousClock.Instant,
        outcome: DiagnosticsEvent.Outcome,
        error: HomeKitError? = nil
    ) {
        let duration = start.duration(to: clock.now)
        DiagnosticsLogger.shared.record(
            operation: operation,
            context: DiagnosticsContext(context),
            duration: duration.hkTimeInterval,
            outcome: outcome,
            metadata: error?.diagnosticsMetadata ?? [:]
        )
    }
}

#else

/// A strongly-typed wrapper for HomeKit accessories (stub for non-HomeKit platforms).
@MainActor
public final class Accessory {
    public var name: String { "" }
    public var uniqueIdentifier: UUID { UUID() }
    public var isReachable: Bool { false }
    public var isBlocked: Bool { false }
    public var supportsIdentify: Bool { false }

    internal init() {}

    public func service(ofType serviceType: String) -> Service? {
        nil
    }

    public func allServices() -> [Service] {
        []
    }

    public func service<T: GeneratedService>(of type: T.Type) -> T? {
        nil
    }

    public func services<T: GeneratedService>(of type: T.Type) -> [T] {
        []
    }

    public func warmUpCache(includeCharacteristics: Bool = false) {
        DiagnosticsLogger.shared.record(
            operation: .cacheWarmUp,
            context: DiagnosticsContext(),
            duration: 0,
            outcome: .success,
            metadata: ["scope": "accessory-stub"]
        )
    }

    public func resetCache(includeCharacteristics: Bool = false) {
        DiagnosticsLogger.shared.record(
            operation: .cacheReset,
            context: DiagnosticsContext(),
            duration: 0,
            outcome: .success,
            metadata: ["scope": includeCharacteristics ? "accessory+characteristics-stub" : "accessory-stub"]
        )
    }

    public func identify() async throws {
        throw HomeKitError.platformUnavailable(reason: "HomeKit accessory identification is unavailable on this platform.")
    }

    public func updateName(_ name: String) async throws {
        throw HomeKitError.platformUnavailable(reason: "HomeKit accessory configuration is unavailable on this platform.")
    }
}


#endif
