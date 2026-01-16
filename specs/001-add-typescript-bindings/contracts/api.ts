/**
 * HomeAtlas TypeScript API Contract
 *
 * This file defines the public API surface for react-native-homeatlas.
 * Implementation must conform to these interfaces.
 *
 * @packageDocumentation
 */

// =============================================================================
// Value Types
// =============================================================================

/** Possible characteristic value types */
export type CharacteristicValue = boolean | number | string | number[];

/** UUID string format */
export type UUID = string;

// =============================================================================
// Entity Types
// =============================================================================

/**
 * HomeKit accessory category enumeration.
 * Maps to HMAccessoryCategory in HomeKit.
 */
export type AccessoryCategory =
  | 'other'
  | 'bridge'
  | 'fan'
  | 'garageDoorOpener'
  | 'lightbulb'
  | 'doorLock'
  | 'outlet'
  | 'switch'
  | 'thermostat'
  | 'sensor'
  | 'securitySystem'
  | 'door'
  | 'window'
  | 'windowCovering'
  | 'programmableSwitch'
  | 'ipCamera'
  | 'videoDoorbell'
  | 'airPurifier'
  | 'airHeater'
  | 'airConditioner'
  | 'airHumidifier'
  | 'airDehumidifier'
  | 'sprinkler'
  | 'faucet'
  | 'showerHead'
  | 'television'
  | 'router';

/**
 * Represents a room within a home.
 */
export interface Room {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** User-assigned room name */
  readonly name: string;
}

/**
 * Represents a characteristic (property) of a service.
 */
export interface Characteristic<T extends CharacteristicValue = CharacteristicValue> {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** Characteristic type identifier (e.g., 'on', 'brightness') */
  readonly type: string;
  /** Current value */
  readonly value: T;
  /** Whether the characteristic can be read */
  readonly supportsRead: boolean;
  /** Whether the characteristic can be written */
  readonly supportsWrite: boolean;
  /** Whether the characteristic supports change notifications */
  readonly supportsNotify: boolean;
  /** Minimum allowed value (for numeric characteristics) */
  readonly minValue: number | null;
  /** Maximum allowed value (for numeric characteristics) */
  readonly maxValue: number | null;
  /** Increment step (for numeric characteristics) */
  readonly stepValue: number | null;
}

/**
 * Represents a functional unit of an accessory (e.g., lightbulb, thermostat).
 */
export interface Service {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** Service type identifier */
  readonly type: string;
  /** User-assigned service name */
  readonly name: string | null;
  /** Whether this is the primary service of the accessory */
  readonly isPrimary: boolean;
  /** Characteristics (properties) of this service */
  readonly characteristics: Characteristic[];
}

/**
 * Represents a HomeKit accessory (physical or bridged device).
 */
export interface Accessory {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** User-assigned device name */
  readonly name: string;
  /** Whether the device is currently reachable */
  readonly isReachable: boolean;
  /** Whether the device is blocked by the user */
  readonly isBlocked: boolean;
  /** Device category */
  readonly category: AccessoryCategory;
  /** Room assignment (UUID), null if not assigned */
  readonly roomId: UUID | null;
  /** Services provided by this accessory */
  readonly services: Service[];
}

/**
 * Represents a HomeKit home.
 */
export interface Home {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** User-assigned home name */
  readonly name: string;
  /** Whether this is the user's primary home */
  readonly isPrimary: boolean;
  /** Accessories in this home */
  readonly accessories: Accessory[];
  /** Rooms in this home */
  readonly rooms: Room[];
}

// =============================================================================
// Error Types
// =============================================================================

/**
 * Error codes for HomeAtlas operations.
 */
export type HomeAtlasErrorCode =
  | 'permissionDenied'
  | 'deviceUnreachable'
  | 'operationNotSupported'
  | 'invalidValue'
  | 'timeout'
  | 'platformUnavailable'
  | 'unknown';

/**
 * Structured error with context for debugging.
 */
export interface HomeAtlasError extends Error {
  /** Error classification */
  readonly code: HomeAtlasErrorCode;
  /** Human-readable description */
  readonly message: string;
  /** Related accessory UUID (if applicable) */
  readonly accessoryId: UUID | null;
  /** Accessory name for display (if applicable) */
  readonly accessoryName: string | null;
  /** Related characteristic type (if applicable) */
  readonly characteristicType: string | null;
  /** Original error message from HomeKit */
  readonly underlyingError: string | null;
}

// =============================================================================
// Event Types
// =============================================================================

/**
 * Event emitted when a subscribed characteristic changes.
 */
export interface CharacteristicChangeEvent {
  /** Source accessory UUID */
  readonly accessoryId: UUID;
  /** Source service type */
  readonly serviceType: string;
  /** Changed characteristic type */
  readonly characteristicType: string;
  /** New value */
  readonly value: CharacteristicValue;
  /** Unix timestamp in milliseconds */
  readonly timestamp: number;
}

/**
 * Subscription handle for unsubscribing.
 */
export interface Subscription {
  /** Unsubscribe from notifications */
  remove(): void;
}

// =============================================================================
// Main API Interface
// =============================================================================

/**
 * Main HomeAtlas API interface.
 *
 * @example
 * ```typescript
 * import HomeAtlas from 'react-native-homeatlas';
 *
 * // Initialize and get homes
 * const homes = await HomeAtlas.initialize();
 *
 * // Read a characteristic
 * const isOn = await HomeAtlas.readCharacteristic(
 *   accessory.id,
 *   'lightbulb',
 *   'on'
 * );
 *
 * // Write a characteristic
 * await HomeAtlas.writeCharacteristic(
 *   accessory.id,
 *   'lightbulb',
 *   'brightness',
 *   75
 * );
 * ```
 */
export interface HomeAtlasAPI {
  // ===========================================================================
  // Initialization
  // ===========================================================================

  /**
   * Initialize HomeAtlas and request HomeKit permissions.
   * Must be called before any other operations.
   *
   * @returns Promise resolving to array of discovered homes
   * @throws {HomeAtlasError} with code 'permissionDenied' if HomeKit access denied
   * @throws {HomeAtlasError} with code 'platformUnavailable' if not on iOS
   */
  initialize(): Promise<Home[]>;

  /**
   * Check if HomeAtlas is ready (initialized with permissions).
   *
   * @returns true if ready, false otherwise
   */
  isReady(): boolean;

  // ===========================================================================
  // Discovery
  // ===========================================================================

  /**
   * Get all discovered homes.
   *
   * @returns Promise resolving to array of homes
   * @throws {HomeAtlasError} if not initialized
   */
  getHomes(): Promise<Home[]>;

  /**
   * Get a specific home by ID.
   *
   * @param homeId - Home UUID
   * @returns Promise resolving to home or null if not found
   */
  getHome(homeId: UUID): Promise<Home | null>;

  /**
   * Get all accessories across all homes.
   *
   * @returns Promise resolving to array of accessories
   */
  getAllAccessories(): Promise<Accessory[]>;

  /**
   * Get a specific accessory by ID.
   *
   * @param accessoryId - Accessory UUID
   * @returns Promise resolving to accessory or null if not found
   */
  getAccessory(accessoryId: UUID): Promise<Accessory | null>;

  /**
   * Find an accessory by name.
   *
   * @param name - Accessory name (case-insensitive)
   * @returns Promise resolving to first matching accessory or null
   */
  findAccessoryByName(name: string): Promise<Accessory | null>;

  // ===========================================================================
  // Characteristic Operations
  // ===========================================================================

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
  readCharacteristic(
    accessoryId: UUID,
    serviceType: string,
    characteristicType: string
  ): Promise<CharacteristicValue>;

  /**
   * Write a characteristic value.
   *
   * @param accessoryId - Accessory UUID
   * @param serviceType - Service type (e.g., 'lightbulb')
   * @param characteristicType - Characteristic type (e.g., 'on', 'brightness')
   * @param value - Value to write
   * @throws {HomeAtlasError} with code 'deviceUnreachable' if device offline
   * @throws {HomeAtlasError} with code 'operationNotSupported' if not writable
   * @throws {HomeAtlasError} with code 'invalidValue' if value out of range
   */
  writeCharacteristic(
    accessoryId: UUID,
    serviceType: string,
    characteristicType: string,
    value: CharacteristicValue
  ): Promise<void>;

  // ===========================================================================
  // Subscriptions
  // ===========================================================================

  /**
   * Subscribe to characteristic change notifications.
   *
   * @param accessoryId - Accessory UUID
   * @param characteristicType - Characteristic type to monitor
   * @param callback - Function called when value changes
   * @returns Subscription handle for unsubscribing
   * @throws {HomeAtlasError} with code 'operationNotSupported' if not notifiable
   */
  subscribe(
    accessoryId: UUID,
    characteristicType: string,
    callback: (event: CharacteristicChangeEvent) => void
  ): Subscription;

  /**
   * Remove all active subscriptions.
   */
  unsubscribeAll(): void;

  // ===========================================================================
  // Utilities
  // ===========================================================================

  /**
   * Refresh the accessory cache.
   * Call this to get updated device states.
   *
   * @returns Promise resolving when refresh completes
   */
  refresh(): Promise<void>;

  /**
   * Identify an accessory (causes device to flash/beep).
   *
   * @param accessoryId - Accessory UUID
   * @throws {HomeAtlasError} with code 'deviceUnreachable' if device offline
   */
  identify(accessoryId: UUID): Promise<void>;
}

// =============================================================================
// Module Export Type
// =============================================================================

/**
 * Default export type for the HomeAtlas module.
 */
declare const HomeAtlas: HomeAtlasAPI;
export default HomeAtlas;
