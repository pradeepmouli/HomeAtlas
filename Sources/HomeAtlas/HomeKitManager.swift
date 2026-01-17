import Foundation

#if canImport(HomeKit)
import HomeKit
import Combine

/// A MainActor-bound manager for discovering and accessing HomeKit homes and accessories.
///
/// HomeKitManager wraps HMHomeManager and provides async/await APIs for home discovery
/// and accessory enumeration.
///
/// Reference: https://developer.apple.com/documentation/homekit/hmhomemanager
@MainActor
public final class HomeKitManager: NSObject, ObservableObject {
    private let homeManager: HMHomeManager
    private var accessoryCache: [UUID: Accessory] = [:]

    /// Published array of available homes.
    @Published public private(set) var homes: [HMHome] = []

    /// Indicates whether the home manager has completed initial discovery.
    @Published public private(set) var isReady: Bool = false

    private var readyContinuation: CheckedContinuation<Void, Never>?

    /// Creates a new HomeKit manager instance.
    public override init() {
        self.homeManager = HMHomeManager()
        super.init()
        self.homeManager.delegate = self
    }

    /// Waits for the home manager to complete initial home discovery.
    ///
    /// - Returns: When the home manager has loaded all homes.
    public func waitUntilReady() async {
        guard !isReady else { return }

        await withCheckedContinuation { continuation in
            self.readyContinuation = continuation
        }
    }

    /// Returns the primary home, if one is configured.
    @available(iOS, deprecated: 16.1, message: "primaryHome is deprecated by Apple; use homes.first or user selection instead")
    @available(macOS, deprecated: 13.0, message: "primaryHome is deprecated by Apple; use homes.first or user selection instead")
    public var primaryHome: HMHome? {
        homeManager.primaryHome
    }

    /// Returns all accessories across all homes.
    public func allAccessories() -> [Accessory] {
        homes.flatMap { home in
            home.accessories.map { cachedAccessory(for: $0) }
        }
    }

    /// Finds an accessory by name across all homes.
    ///
    /// - Parameter name: The accessory name to search for.
    /// - Returns: The first matching accessory, or nil if not found.
    public func accessory(named name: String) -> Accessory? {
        for home in homes {
            if let hmAccessory = home.accessories.first(where: { $0.name == name }) {
                return cachedAccessory(for: hmAccessory)
            }
        }
        return nil
    }

    /// Finds a home by name.
    ///
    /// - Parameter name: The home name to search for.
    /// - Returns: The matching home, or nil if not found.
    public func home(named name: String) -> HMHome? {
        homes.first { $0.name == name }
    }

    /// Warms the accessory cache and optionally primes service and characteristic caches for each accessory.
    ///
    /// - Parameters:
    ///   - includeServices: When true, calls `allServices()` on every accessory to create service wrappers.
    ///   - includeCharacteristics: When true, invokes `warmUpCharacteristicCache()` on each service after warming.
    public func warmUpCache(includeServices: Bool = false, includeCharacteristics: Bool = false) {
        let clock = ContinuousClock()
        let start = clock.now

        let accessories = allAccessories()

        if includeServices || includeCharacteristics {
            accessories.forEach { accessory in
                let services = accessory.allServices()
                if includeCharacteristics {
                    services.forEach { $0.warmUpCharacteristicCache() }
                }
            }
        }

        let duration = start.duration(to: clock.now).hkTimeInterval
        DiagnosticsLogger.shared.record(
            operation: .cacheWarmUp,
            context: DiagnosticsContext(),
            duration: duration,
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "manager+services+characteristics" : (includeServices ? "manager+services" : "manager"),
                "accessories.count": String(accessories.count)
            ]
        )
    }

    /// Clears all accessory, service, and characteristic caches, emitting diagnostics for observability.
    ///
    /// - Parameter includeCharacteristics: When true, resets characteristic caches on each cached service before removal.
    public func resetCache(includeCharacteristics: Bool = false) {
        accessoryCache.values.forEach { accessory in
            accessory.resetCache(includeCharacteristics: includeCharacteristics)
        }

        let removed = accessoryCache.count
        accessoryCache.removeAll()

        DiagnosticsLogger.shared.record(
            operation: .cacheReset,
            context: DiagnosticsContext(),
            duration: 0,
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "manager+services+characteristics" : "manager",
                "accessories.removed": String(removed)
            ]
        )
    }
}

extension HomeKitManager: HMHomeManagerDelegate {
    public nonisolated func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Task { @MainActor in
            self.homes = manager.homes
            self.pruneAccessoryCache(for: manager.homes)
            if !self.isReady {
                self.isReady = true
                self.readyContinuation?.resume()
                self.readyContinuation = nil
            }
        }
    }

    public nonisolated func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        Task { @MainActor in
            self.objectWillChange.send()
        }
    }
}

private extension HomeKitManager {
    func cachedAccessory(for hmAccessory: HMAccessory) -> Accessory {
        let key: UUID = hmAccessory.uniqueIdentifier
        if let cached: Accessory = accessoryCache[key] {
            return cached
        }

        let wrapper: Accessory = Accessory(underlying: hmAccessory)
        accessoryCache[key] = wrapper
        return wrapper
    }

    func pruneAccessoryCache(for homes: [HMHome]) {
        let currentIdentifiers: Set<UUID> = homes.reduce(into: Set<UUID>()) { result, home in
            home.accessories.forEach { result.insert($0.uniqueIdentifier) }
        }

        accessoryCache = accessoryCache.filter { currentIdentifiers.contains($0.key) }
    }
}

#else

/// Stub implementations for platforms without HomeKit support.
/// Provides conditional compilation based on Combine availability.

/// Private helper for shared stub implementation logic.
@MainActor
private enum StubHelpers {
    static func warmUpCache(includeServices: Bool, includeCharacteristics: Bool) {
        DiagnosticsLogger.shared.record(
            operation: .cacheWarmUp,
            context: DiagnosticsContext(),
            duration: 0.001, // Stub duration
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "manager+services+characteristics" : (includeServices ? "manager+services" : "manager"),
                "accessories.count": "0"
            ]
        )
    }
    
    static func resetCache(includeCharacteristics: Bool) {
        DiagnosticsLogger.shared.record(
            operation: .cacheReset,
            context: DiagnosticsContext(),
            duration: 0.001, // Stub duration
            outcome: .success,
            metadata: [
                "scope": includeCharacteristics ? "manager+services+characteristics" : "manager",
                "accessories.removed": "0"
            ]
        )
    }
}

#if canImport(Combine)
import Combine

/// A stub HomeKit manager for non-HomeKit platforms with Combine support.
@MainActor
public final class HomeKitManager: ObservableObject {
    @Published public private(set) var homes: [String] = []
    @Published public private(set) var isReady: Bool = true

    public init() {}

    public func waitUntilReady() async {
        // Already ready
    }

    public var primaryHome: String? { nil }

    public func allAccessories() -> [Accessory] {
        []
    }

    public func accessory(named name: String) -> Accessory? {
        nil
    }

    public func home(named name: String) -> String? {
        nil
    }

    public func warmUpCache(includeServices: Bool = false, includeCharacteristics: Bool = false) {
        StubHelpers.warmUpCache(includeServices: includeServices, includeCharacteristics: includeCharacteristics)
    }

    public func resetCache(includeCharacteristics: Bool = false) {
        StubHelpers.resetCache(includeCharacteristics: includeCharacteristics)
    }
}

#else

/// A stub HomeKit manager for non-HomeKit platforms without Combine.
@MainActor
public final class HomeKitManager {
    public private(set) var homes: [String] = []
    public private(set) var isReady: Bool = true

    public init() {}

    public func waitUntilReady() async {
        // Already ready
    }

    public var primaryHome: String? { nil }

    public func allAccessories() -> [Accessory] {
        []
    }

    public func accessory(named name: String) -> Accessory? {
        nil
    }

    public func home(named name: String) -> String? {
        nil
    }

    public func warmUpCache(includeServices: Bool = false, includeCharacteristics: Bool = false) {
        StubHelpers.warmUpCache(includeServices: includeServices, includeCharacteristics: includeCharacteristics)
    }

    public func resetCache(includeCharacteristics: Bool = false) {
        StubHelpers.resetCache(includeCharacteristics: includeCharacteristics)
    }
}

#endif

#endif
