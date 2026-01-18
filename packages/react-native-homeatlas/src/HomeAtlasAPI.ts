/**
 * Main HomeAtlas API implementation
 * @packageDocumentation
 */

import { NativeModules, NativeEventEmitter, Platform } from 'react-native';
import type {
  Home,
  Accessory,
  CharacteristicValue,
  UUID,
  CharacteristicChangeEvent,
  Subscription,
  ModuleState,
} from './types';
import { HomeAtlasError } from './HomeAtlasError';
import { DebugLogger } from './utils/DebugLogger';

// Get native module
const { HomeAtlas: NativeHomeAtlas } = NativeModules;

if (!NativeHomeAtlas) {
  console.error(
    'HomeAtlas native module not found. Make sure the package is properly linked.'
  );
}

// Create event emitter for subscriptions
const eventEmitter = NativeHomeAtlas
  ? new NativeEventEmitter(NativeHomeAtlas)
  : null;

/**
 * Main HomeAtlas API class.
 * 
 * Provides type-safe access to HomeKit functionality through React Native.
 */
class HomeAtlasAPI {
  private subscriptions: Map<string, { remove: () => void }> = new Map();

  // MARK: - Initialization

  /**
   * Initialize HomeAtlas and request HomeKit permissions.
   * Must be called before any other operations.
   * 
   * @returns Promise resolving to array of discovered homes
   * @throws {HomeAtlasError} with code 'permissionDenied' if HomeKit access denied
   * @throws {HomeAtlasError} with code 'platformUnavailable' if not on iOS
   */
  async initialize(): Promise<Home[]> {
    this.ensureNativeModuleAvailable();
    
    if (Platform.OS !== 'ios') {
      throw HomeAtlasError.platformUnavailable();
    }

    try {
      DebugLogger.log('Initializing HomeAtlas...');
      const homes = await NativeHomeAtlas.initialize();
      DebugLogger.log('HomeAtlas initialized successfully', { homeCount: homes.length });
      return homes;
    } catch (error) {
      DebugLogger.error('Failed to initialize HomeAtlas', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Check if HomeAtlas is ready (initialized with permissions).
   * 
   * @returns true if ready, false otherwise
   */
  isReady(): boolean {
    if (Platform.OS !== 'ios' || !NativeHomeAtlas) {
      return false;
    }

    try {
      return NativeHomeAtlas.isReady();
    } catch (error) {
      DebugLogger.error('Failed to check ready state', error);
      return false;
    }
  }

  /**
   * Get current module state.
   * 
   * @returns Current module state (uninitialized, ready, permissionDenied, error)
   */
  getState(): ModuleState {
    if (Platform.OS !== 'ios' || !NativeHomeAtlas) {
      return 'error';
    }

    try {
      return NativeHomeAtlas.getState() as ModuleState;
    } catch (error) {
      DebugLogger.error('Failed to get state', error);
      return 'error';
    }
  }

  // MARK: - Discovery

  /**
   * Get all discovered homes.
   * 
   * @returns Promise resolving to array of homes
   * @throws {HomeAtlasError} if not initialized
   */
  async getHomes(): Promise<Home[]> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Getting homes...');
      const homes = await NativeHomeAtlas.getHomes();
      DebugLogger.log('Retrieved homes', { count: homes.length });
      return homes;
    } catch (error) {
      DebugLogger.error('Failed to get homes', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Get a specific home by ID.
   * 
   * @param homeId - Home UUID
   * @returns Promise resolving to home or null if not found
   */
  async getHome(homeId: UUID): Promise<Home | null> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Getting home', { homeId });
      const home = await NativeHomeAtlas.getHome(homeId);
      return home;
    } catch (error) {
      DebugLogger.error('Failed to get home', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Get all accessories across all homes.
   * 
   * @returns Promise resolving to array of accessories
   */
  async getAllAccessories(): Promise<Accessory[]> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Getting all accessories...');
      const accessories = await NativeHomeAtlas.getAllAccessories();
      DebugLogger.log('Retrieved accessories', { count: accessories.length });
      return accessories;
    } catch (error) {
      DebugLogger.error('Failed to get accessories', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Get a specific accessory by ID.
   * 
   * @param accessoryId - Accessory UUID
   * @returns Promise resolving to accessory or null if not found
   */
  async getAccessory(accessoryId: UUID): Promise<Accessory | null> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Getting accessory', { accessoryId });
      const accessory = await NativeHomeAtlas.getAccessory(accessoryId);
      return accessory;
    } catch (error) {
      DebugLogger.error('Failed to get accessory', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Find an accessory by name.
   * 
   * @param name - Accessory name (case-insensitive)
   * @returns Promise resolving to first matching accessory or null
   */
  async findAccessoryByName(name: string): Promise<Accessory | null> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Finding accessory by name', { name });
      const accessory = await NativeHomeAtlas.findAccessoryByName(name);
      return accessory;
    } catch (error) {
      DebugLogger.error('Failed to find accessory', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  // MARK: - Characteristic Operations

  /**
   * Read a characteristic value.
   * 
   * @param accessoryId - Accessory UUID
   * @param serviceType - Service type (e.g., 'lightbulb')
   * @param characteristicType - Characteristic type (e.g., 'on', 'brightness')
   * @returns Promise resolving to the characteristic value
   * @throws {HomeAtlasError} with code 'deviceUnreachable' if device offline
   * @throws {HomeAtlasError} with code 'operationNotSupported' if not readable
   */
  async readCharacteristic(
    accessoryId: UUID,
    serviceType: string,
    characteristicType: string
  ): Promise<CharacteristicValue> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Reading characteristic', {
        accessoryId,
        serviceType,
        characteristicType,
      });
      const value = await NativeHomeAtlas.readCharacteristic(
        accessoryId,
        serviceType,
        characteristicType
      );
      DebugLogger.log('Read characteristic value', { value });
      return value;
    } catch (error) {
      DebugLogger.error('Failed to read characteristic', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Write a characteristic value.
   * 
   * @param accessoryId - Accessory UUID
   * @param serviceType - Service type (e.g., 'lightbulb')
   * @param characteristicType - Characteristic type (e.g., 'on', 'brightness')
   * @param value - Value to write
   * @param mode - Write mode ('optimistic' | 'confirmed'), defaults to 'confirmed'
   * @throws {HomeAtlasError} with code 'deviceUnreachable' if device offline
   * @throws {HomeAtlasError} with code 'operationNotSupported' if not writable
   * @throws {HomeAtlasError} with code 'invalidValue' if value out of range
   */
  async writeCharacteristic(
    accessoryId: UUID,
    serviceType: string,
    characteristicType: string,
    value: CharacteristicValue,
    mode: 'optimistic' | 'confirmed' = 'confirmed'
  ): Promise<void> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Writing characteristic', {
        accessoryId,
        serviceType,
        characteristicType,
        value,
        mode,
      });
      await NativeHomeAtlas.writeCharacteristic(
        accessoryId,
        serviceType,
        characteristicType,
        value,
        mode
      );
      DebugLogger.log('Wrote characteristic value successfully');
    } catch (error) {
      DebugLogger.error('Failed to write characteristic', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  // MARK: - Subscriptions

  /**
   * Subscribe to characteristic change notifications.
   * 
   * @param accessoryId - Accessory UUID
   * @param characteristicType - Characteristic type to monitor
   * @param callback - Function called when value changes
   * @param serviceType - Optional service type
   * @returns Subscription handle for unsubscribing
   * @throws {HomeAtlasError} with code 'operationNotSupported' if not notifiable
   */
  subscribe(
    accessoryId: UUID,
    characteristicType: string,
    callback: (event: CharacteristicChangeEvent) => void,
    serviceType?: string
  ): Subscription {
    this.ensureNativeModuleAvailable();
    
    if (Platform.OS !== 'ios') {
      throw HomeAtlasError.platformUnavailable();
    }

    try {
      DebugLogger.log('Subscribing to characteristic', {
        accessoryId,
        characteristicType,
        serviceType,
      });

      // Subscribe via native module
      const subscriptionId = NativeHomeAtlas.subscribe(
        accessoryId,
        characteristicType,
        serviceType
      );

      // Set up event listener
      const listener = eventEmitter?.addListener(
        'onCharacteristicChange',
        (event: CharacteristicChangeEvent) => {
          // Filter events for this subscription
          if (
            event.accessoryId === accessoryId &&
            event.characteristicType === characteristicType &&
            (!serviceType || event.serviceType === serviceType)
          ) {
            DebugLogger.log('Characteristic changed', event);
            callback(event);
          }
        }
      );

      // Store subscription
      this.subscriptions.set(subscriptionId, listener);

      DebugLogger.log('Subscribed successfully', { subscriptionId });

      // Return subscription handle
      return {
        remove: () => {
          DebugLogger.log('Unsubscribing', { subscriptionId });
          listener?.remove();
          NativeHomeAtlas.unsubscribe(subscriptionId);
          this.subscriptions.delete(subscriptionId);
        },
      };
    } catch (error) {
      DebugLogger.error('Failed to subscribe', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Remove all active subscriptions.
   * 
   * **Important**: Call this method in component cleanup (e.g., useEffect return)
   * to prevent memory leaks. Subscriptions will not be automatically cleaned up
   * when the component unmounts.
   */
  unsubscribeAll(): void {
    DebugLogger.log('Unsubscribing all subscriptions');

    // Remove all event listeners
    for (const listener of this.subscriptions.values()) {
      listener?.remove();
    }
    this.subscriptions.clear();

    // Clear native subscriptions
    if (Platform.OS === 'ios' && NativeHomeAtlas) {
      NativeHomeAtlas.unsubscribeAll();
    }
  }

  // MARK: - Utilities

  /**
   * Refresh the accessory cache.
   * Call this to get updated device states.
   * 
   * @returns Promise resolving when refresh completes
   */
  async refresh(): Promise<void> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Refreshing accessory cache...');
      await NativeHomeAtlas.refresh();
      DebugLogger.log('Cache refreshed successfully');
    } catch (error) {
      DebugLogger.error('Failed to refresh cache', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Identify an accessory (causes device to flash/beep).
   * 
   * @param accessoryId - Accessory UUID
   * @throws {HomeAtlasError} with code 'deviceUnreachable' if device offline
   */
  async identify(accessoryId: UUID): Promise<void> {
    this.ensureNativeModuleAvailable();
    
    try {
      DebugLogger.log('Identifying accessory', { accessoryId });
      await NativeHomeAtlas.identify(accessoryId);
      DebugLogger.log('Identify command sent successfully');
    } catch (error) {
      DebugLogger.error('Failed to identify accessory', error);
      throw HomeAtlasError.fromNativeError(error);
    }
  }

  /**
   * Enable or disable debug logging.
   * 
   * @param enabled - Whether to enable debug logging
   */
  setDebugLoggingEnabled(enabled: boolean): void {
    DebugLogger.setEnabled(enabled);
    if (Platform.OS === 'ios' && NativeHomeAtlas) {
      NativeHomeAtlas.setDebugLoggingEnabled(enabled);
    }
  }

  // MARK: - Private Helpers

  /**
   * Ensure the native module is available before making calls.
   * @throws {HomeAtlasError} if native module is not loaded
   */
  private ensureNativeModuleAvailable(): void {
    if (!NativeHomeAtlas) {
      throw HomeAtlasError.unknown(
        'HomeAtlas native module not found. Make sure the package is properly linked.'
      );
    }
  }
}

// Export singleton instance
export default new HomeAtlasAPI();
