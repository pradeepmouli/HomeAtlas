/**
 * Characteristic type definitions
 * @packageDocumentation
 */

import type { UUID, CharacteristicValue } from './index';

/**
 * Represents a characteristic (property) of a service.
 * Based on CharacteristicSnapshot from HomeAtlas encoding.
 */
export interface Characteristic<T extends CharacteristicValue = CharacteristicValue> {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** Characteristic type identifier (e.g., 'PowerState', 'Brightness') */
  readonly characteristicType: string;
  /** Localized display name */
  readonly displayName?: string;
  /** Unit of measurement (e.g., '%', '°C') */
  readonly unit?: string;
  /** Minimum allowed value (for numeric characteristics) */
  readonly min?: number;
  /** Maximum allowed value (for numeric characteristics) */
  readonly max?: number;
  /** Increment step (for numeric characteristics) */
  readonly step?: number;
  /** Whether the characteristic can be read */
  readonly readable: boolean;
  /** Whether the characteristic can be written */
  readonly writable: boolean;
  /** Current value (null if not readable or unavailable) */
  readonly value?: T | null;
  /** Reason value is unavailable (e.g., 'unavailable', 'not-readable') */
  readonly reason?: string;
}
