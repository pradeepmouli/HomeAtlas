//
//  HomeAtlasModule.swift
//  react-native-homeatlas
//
//  Expo Module for HomeAtlas - HomeKit control for React Native
//

import ExpoModulesCore
import Foundation

#if canImport(HomeKit)
import HomeKit

/// HomeAtlasModule exposes HomeKit functionality to React Native/Expo.
///
/// This module provides async APIs for:
/// - Home and accessory discovery
/// - Characteristic read/write operations
/// - Real-time characteristic change notifications
/// - Structured error handling with context
@MainActor
public class HomeAtlasModule: Module {
    // MARK: - Properties
    
    private var homeManager: HMHomeManager?
    private var moduleState: ModuleState = .uninitialized
    private var isManagerReady = false
    private var readyContinuation: CheckedContinuation<Void, Never>?
    private var subscriptions: [String: CharacteristicSubscription] = [:]
    
    // MARK: - Module State
    
    /// Module state enumeration matching TypeScript ModuleState type.
    enum ModuleState: String {
        case uninitialized
        case ready
        case permissionDenied
        case error
    }
    
    /// Subscription tracking for characteristic notifications.
    struct CharacteristicSubscription {
        let accessoryId: UUID
        let characteristicType: String
        let serviceType: String?
    }
    
    // MARK: - Module Definition
    
    public func definition() -> ModuleDefinition {
        Name("HomeAtlas")
        
        // Event for characteristic change notifications
        Events("onCharacteristicChange")
        
        // MARK: Initialization
        
        AsyncFunction("initialize") { (promise: Promise) in
            do {
                try await self.initialize()
                let homes = self.homeManager?.homes.map { Serialization.serializeHome($0) } ?? []
                promise.resolve(homes)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        Function("isReady") { () -> Bool in
            return self.isManagerReady && self.moduleState == .ready
        }
        
        Function("getState") { () -> String in
            return self.moduleState.rawValue
        }
        
        // MARK: Discovery
        
        AsyncFunction("getHomes") { (promise: Promise) in
            do {
                let homes = try await self.getHomes()
                promise.resolve(homes)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("getHome") { (homeId: String, promise: Promise) in
            do {
                let home = try await self.getHome(homeId: homeId)
                promise.resolve(home)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("getAllAccessories") { (promise: Promise) in
            do {
                let accessories = try await self.getAllAccessories()
                promise.resolve(accessories)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("getAccessory") { (accessoryId: String, promise: Promise) in
            do {
                let accessory = try await self.getAccessory(accessoryId: accessoryId)
                promise.resolve(accessory)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("findAccessoryByName") { (name: String, promise: Promise) in
            do {
                let accessory = try await self.findAccessoryByName(name: name)
                promise.resolve(accessory)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("refresh") { (promise: Promise) in
            do {
                try await self.refresh()
                promise.resolve(nil)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        // MARK: Characteristic Operations
        
        AsyncFunction("readCharacteristic") { (accessoryId: String, serviceType: String, characteristicType: String, promise: Promise) in
            do {
                let value = try await self.readCharacteristic(
                    accessoryId: accessoryId,
                    serviceType: serviceType,
                    characteristicType: characteristicType
                )
                promise.resolve(value)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("writeCharacteristic") { (accessoryId: String, serviceType: String, characteristicType: String, value: Any, mode: String?, promise: Promise) in
            do {
                try await self.writeCharacteristic(
                    accessoryId: accessoryId,
                    serviceType: serviceType,
                    characteristicType: characteristicType,
                    value: value,
                    mode: mode ?? "confirmed"
                )
                promise.resolve(nil)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        AsyncFunction("identify") { (accessoryId: String, promise: Promise) in
            do {
                try await self.identify(accessoryId: accessoryId)
                promise.resolve(nil)
            } catch {
                promise.reject(self.createError(from: error))
            }
        }
        
        // MARK: Subscriptions
        
        Function("subscribe") { (accessoryId: String, characteristicType: String, serviceType: String?) -> String in
            return self.subscribe(
                accessoryId: accessoryId,
                characteristicType: characteristicType,
                serviceType: serviceType
            )
        }
        
        Function("unsubscribe") { (subscriptionId: String) in
            self.unsubscribe(subscriptionId: subscriptionId)
        }
        
        Function("unsubscribeAll") {
            self.unsubscribeAll()
        }
        
        // MARK: Utilities
        
        Function("setDebugLoggingEnabled") { (enabled: Bool) in
            // TODO: Implement debug logging
        }
    }
    
    // MARK: - Initialization Implementation
    
    private func initialize() async throws {
        // Check if already initialized
        if self.isManagerReady && self.moduleState == .ready {
            return
        }
        
        // Create home manager if needed
        if self.homeManager == nil {
            self.homeManager = HMHomeManager()
        }
        
        // Wait for home manager to be ready
        try await waitForHomeManager()
        
        // Update state
        self.moduleState = .ready
        self.isManagerReady = true
    }
    
    private func waitForHomeManager() async throws {
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        // Check if already ready (homes are loaded)
        if !homeManager.homes.isEmpty {
            return
        }
        
        // Wait for homes to be loaded using async/await
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.readyContinuation = continuation
            
            // Set up a timer as a fallback (5 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if let cont = self.readyContinuation {
                    self.readyContinuation = nil
                    cont.resume()
                }
            }
        }
    }
    
    // MARK: - Discovery Implementation
    
    private func getHomes() async throws -> [[String: Any]] {
        try ensureInitialized()
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        return homeManager.homes.map { Serialization.serializeHome($0) }
    }
    
    private func getHome(homeId: String) async throws -> [String: Any]? {
        try ensureInitialized()
        
        guard let uuid = UUID(uuidString: homeId) else {
            throw HomeAtlasError.invalidValue("Invalid home ID format")
        }
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        if let home = homeManager.homes.first(where: { $0.uniqueIdentifier == uuid }) {
            return Serialization.serializeHome(home)
        }
        
        return nil
    }
    
    private func getAllAccessories() async throws -> [[String: Any]] {
        try ensureInitialized()
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        let allAccessories = homeManager.homes.flatMap { $0.accessories }
        return allAccessories.map { Serialization.serializeAccessory($0) }
    }
    
    private func getAccessory(accessoryId: String) async throws -> [String: Any]? {
        try ensureInitialized()
        
        guard let uuid = UUID(uuidString: accessoryId) else {
            throw HomeAtlasError.invalidValue("Invalid accessory ID format")
        }
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        for home in homeManager.homes {
            if let accessory = home.accessories.first(where: { $0.uniqueIdentifier == uuid }) {
                return Serialization.serializeAccessory(accessory)
            }
        }
        
        return nil
    }
    
    private func findAccessoryByName(name: String) async throws -> [String: Any]? {
        try ensureInitialized()
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        let lowerName = name.lowercased()
        
        for home in homeManager.homes {
            if let accessory = home.accessories.first(where: { $0.name.lowercased() == lowerName }) {
                return Serialization.serializeAccessory(accessory)
            }
        }
        
        return nil
    }
    
    private func refresh() async throws {
        // Clear any cached data and reload
        // Note: HomeKit automatically refreshes, so this is a no-op
        // but we keep it for API compatibility
    }
    
    // MARK: - Characteristic Operations Implementation
    
    private func readCharacteristic(accessoryId: String, serviceType: String, characteristicType: String) async throws -> Any {
        try ensureInitialized()
        
        let characteristic = try await findCharacteristic(
            accessoryId: accessoryId,
            serviceType: serviceType,
            characteristicType: characteristicType
        )
        
        // Check if readable
        guard characteristic.properties.contains(HMCharacteristicPropertyReadable) else {
            throw HomeAtlasError.operationNotSupported("Characteristic is not readable")
        }
        
        // Read value from HomeKit
        try await characteristic.readValue()
        
        // Return serialized value
        if let value = characteristic.value {
            return Serialization.serializeCharacteristicValue(value)
        } else {
            throw HomeAtlasError.unknown("Failed to read characteristic value")
        }
    }
    
    private func writeCharacteristic(accessoryId: String, serviceType: String, characteristicType: String, value: Any, mode: String) async throws {
        try ensureInitialized()
        
        let characteristic = try await findCharacteristic(
            accessoryId: accessoryId,
            serviceType: serviceType,
            characteristicType: characteristicType
        )
        
        // Check if writable
        guard characteristic.properties.contains(HMCharacteristicPropertyWritable) else {
            throw HomeAtlasError.operationNotSupported("Characteristic is not writable")
        }
        
        // Deserialize value
        guard let writeValue = Serialization.deserializeCharacteristicValue(value, for: characteristic) else {
            throw HomeAtlasError.invalidValue("Invalid value for characteristic")
        }
        
        // Write based on mode
        if mode == "optimistic" {
            // Fire and forget
            Task {
                try? await characteristic.writeValue(writeValue)
            }
        } else {
            // Wait for confirmation
            try await characteristic.writeValue(writeValue)
        }
    }
    
    private func identify(accessoryId: String) async throws {
        try ensureInitialized()
        
        guard let uuid = UUID(uuidString: accessoryId) else {
            throw HomeAtlasError.invalidValue("Invalid accessory ID format")
        }
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        // Find accessory
        var targetAccessory: HMAccessory?
        for home in homeManager.homes {
            if let accessory = home.accessories.first(where: { $0.uniqueIdentifier == uuid }) {
                targetAccessory = accessory
                break
            }
        }
        
        guard let accessory = targetAccessory else {
            throw HomeAtlasError.deviceUnreachable("Accessory not found")
        }
        
        // Check if identify is supported
        guard accessory.supportsIdentify else {
            throw HomeAtlasError.operationNotSupported("Accessory does not support identify")
        }
        
        // Identify the accessory
        try await accessory.identify()
    }
    
    // MARK: - Subscription Implementation
    
    private func subscribe(accessoryId: String, characteristicType: String, serviceType: String?) -> String {
        let subscriptionId = UUID().uuidString
        
        subscriptions[subscriptionId] = CharacteristicSubscription(
            accessoryId: UUID(uuidString: accessoryId) ?? UUID(),
            characteristicType: characteristicType,
            serviceType: serviceType
        )
        
        // TODO: Enable notification on characteristic
        
        return subscriptionId
    }
    
    private func unsubscribe(subscriptionId: String) {
        subscriptions.removeValue(forKey: subscriptionId)
        
        // TODO: Disable notification on characteristic
    }
    
    private func unsubscribeAll() {
        subscriptions.removeAll()
        
        // TODO: Disable all notifications
    }
    
    // MARK: - Helper Methods
    
    private func ensureInitialized() throws {
        guard self.isManagerReady && self.moduleState == .ready else {
            throw HomeAtlasError.unknown("Module not initialized. Call initialize() first.")
        }
    }
    
    private func findCharacteristic(accessoryId: String, serviceType: String, characteristicType: String) async throws -> HMCharacteristic {
        guard let uuid = UUID(uuidString: accessoryId) else {
            throw HomeAtlasError.invalidValue("Invalid accessory ID format")
        }
        
        guard let homeManager = self.homeManager else {
            throw HomeAtlasError.unknown("Home manager not initialized")
        }
        
        // Find accessory
        var targetAccessory: HMAccessory?
        for home in homeManager.homes {
            if let accessory = home.accessories.first(where: { $0.uniqueIdentifier == uuid }) {
                targetAccessory = accessory
                break
            }
        }
        
        guard let accessory = targetAccessory else {
            throw HomeAtlasError.deviceUnreachable("Accessory not found")
        }
        
        // Find service
        guard let service = accessory.services.first(where: { $0.serviceType == serviceType }) else {
            throw HomeAtlasError.operationNotSupported("Service not found on accessory")
        }
        
        // Find characteristic
        guard let characteristic = service.characteristics.first(where: { $0.characteristicType == characteristicType }) else {
            throw HomeAtlasError.operationNotSupported("Characteristic not found on service")
        }
        
        return characteristic
    }
    
    private func createError(from error: Error) -> Exception {
        if let homeAtlasError = error as? HomeAtlasError {
            return Exception(
                name: "HomeAtlasError",
                description: homeAtlasError.message,
                code: homeAtlasError.code
            )
        } else if let hmError = error as? HMError {
            let code: String
            let message: String
            
            switch hmError.code {
            case .communicationFailure:
                code = "deviceUnreachable"
                message = "Failed to communicate with device"
            case .operationTimedOut:
                code = "timeout"
                message = "Operation timed out"
            case .invalidParameter:
                code = "invalidValue"
                message = "Invalid parameter provided"
            case .operationCancelled:
                code = "unknown"
                message = "Operation was cancelled"
            default:
                code = "unknown"
                message = hmError.localizedDescription
            }
            
            return Exception(
                name: "HomeAtlasError",
                description: message,
                code: code
            )
        } else {
            return Exception(
                name: "HomeAtlasError",
                description: error.localizedDescription,
                code: "unknown"
            )
        }
    }
}

// MARK: - Error Types

enum HomeAtlasError: Error {
    case permissionDenied(String)
    case deviceUnreachable(String)
    case operationNotSupported(String)
    case invalidValue(String)
    case timeout(String)
    case platformUnavailable(String)
    case unknown(String)
    
    var code: String {
        switch self {
        case .permissionDenied: return "permissionDenied"
        case .deviceUnreachable: return "deviceUnreachable"
        case .operationNotSupported: return "operationNotSupported"
        case .invalidValue: return "invalidValue"
        case .timeout: return "timeout"
        case .platformUnavailable: return "platformUnavailable"
        case .unknown: return "unknown"
        }
    }
    
    var message: String {
        switch self {
        case .permissionDenied(let msg): return msg
        case .deviceUnreachable(let msg): return msg
        case .operationNotSupported(let msg): return msg
        case .invalidValue(let msg): return msg
        case .timeout(let msg): return msg
        case .platformUnavailable(let msg): return msg
        case .unknown(let msg): return msg
        }
    }
}

// MARK: - HMHomeManagerDelegate (for ready state)

extension HomeAtlasModule: HMHomeManagerDelegate {
    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        // Resume continuation when homes are loaded
        if let continuation = self.readyContinuation {
            self.readyContinuation = nil
            continuation.resume()
        }
    }
}

#else

// MARK: - Non-iOS Stub

@MainActor
public class HomeAtlasModule: Module {
    public func definition() -> ModuleDefinition {
        Name("HomeAtlas")
        
        AsyncFunction("initialize") { (promise: Promise) in
            promise.reject("platformUnavailable", "HomeKit is only available on iOS")
        }
        
        // Stub all other functions with platform unavailable error
        // ... (abbreviated for brevity)
    }
}

#endif
