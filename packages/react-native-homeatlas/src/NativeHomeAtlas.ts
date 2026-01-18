/**
 * Native module interface for react-native-homeatlas
 * @packageDocumentation
 */

import type { Home, Accessory, CharacteristicValue } from './types';
import type { ModuleState } from './types/state';

/**
 * Native module interface definition.
 * 
 * This interface defines the methods exposed by the native Swift/Kotlin module
 * to the JavaScript layer. All methods are implemented in iOS (HomeAtlasModule.swift)
 * and stubbed on Android (HomeAtlasModule.kt).
 */
export interface NativeHomeAtlas {
  // ===========================================================================
  // Initialization
  // ===========================================================================

  /**
   * Initialize HomeAtlas and request HomeKit permissions.
   * @returns Promise resolving to array of discovered homes
   */
  initialize(): Promise<Home[]>;

  /**
   * Check if HomeAtlas is ready (initialized with permissions).
   * @returns true if ready, false otherwise
   */
  isReady(): boolean;

  /**
   * Get current module state.
   * @returns Current ModuleState
   */
  getState(): ModuleState;

  // ===========================================================================
  // Discovery
  // ===========================================================================

  /**
   * Get all discovered homes.
   * @returns Promise resolving to array of homes
   */
  getHomes(): Promise<Home[]>;

  /**
   * Get a specific home by ID.
   * @param homeId - Home UUID
   * @returns Promise resolving to home or null if not found
   */
  getHome(homeId: string): Promise<Home | null>;

  /**
   * Get all accessories across all homes.
   * @returns Promise resolving to array of accessories
   */
  getAllAccessories(): Promise<Accessory[]>;

  /**
   * Get a specific accessory by ID.
   * @param accessoryId - Accessory UUID
   * @returns Promise resolving to accessory or null if not found
   */
  getAccessory(accessoryId: string): Promise<Accessory | null>;

  /**
   * Find an accessory by name.
   * @param name - Accessory name (case-insensitive)
   * @returns Promise resolving to first matching accessory or null
   */
  findAccessoryByName(name: string): Promise<Accessory | null>;

  /**
   * Refresh the accessory cache.
   * @returns Promise resolving when refresh completes
   */
  refresh(): Promise<void>;

  // ===========================================================================
  // Characteristic Operations
  // ===========================================================================

  /**
   * Read a characteristic value.
   * @param accessoryId - Accessory UUID
   * @param serviceType - Service type
   * @param characteristicType - Characteristic type
   * @returns Promise resolving to the characteristic value
   */
  readCharacteristic(
    accessoryId: string,
    serviceType: string,
    characteristicType: string
  ): Promise<CharacteristicValue>;

  /**
   * Write a characteristic value.
   * @param accessoryId - Accessory UUID
   * @param serviceType - Service type
   * @param characteristicType - Characteristic type
   * @param value - Value to write
   * @param mode - Write mode ('optimistic' | 'confirmed')
   * @returns Promise resolving when write completes
   */
  writeCharacteristic(
    accessoryId: string,
    serviceType: string,
    characteristicType: string,
    value: CharacteristicValue,
    mode?: string
  ): Promise<void>;

  /**
   * Identify an accessory (causes device to flash/beep).
   * @param accessoryId - Accessory UUID
   * @returns Promise resolving when identify completes
   */
  identify(accessoryId: string): Promise<void>;

  // ===========================================================================
  // Subscriptions
  // ===========================================================================

  /**
   * Subscribe to characteristic change notifications.
   * @param accessoryId - Accessory UUID
   * @param characteristicType - Characteristic type to monitor
   * @param serviceType - Optional service type
   * @returns Subscription ID
   */
  subscribe(
    accessoryId: string,
    characteristicType: string,
    serviceType?: string
  ): string;

  /**
   * Unsubscribe from a specific subscription.
   * @param subscriptionId - Subscription ID to remove
   */
  unsubscribe(subscriptionId: string): void;

  /**
   * Remove all active subscriptions.
   */
  unsubscribeAll(): void;

  // ===========================================================================
  // Utilities
  // ===========================================================================

  /**
   * Enable or disable debug logging.
   * @param enabled - Whether to enable debug logging
   */
  setDebugLoggingEnabled(enabled: boolean): void;
}
