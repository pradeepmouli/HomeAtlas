/**
 * Characteristic type definitions
 * @packageDocumentation
 */

import type { UUID, CharacteristicValue } from './index';

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
