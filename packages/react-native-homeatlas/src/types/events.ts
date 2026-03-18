/**
 * Event type definitions for subscriptions
 * @packageDocumentation
 */

import type { UUID, CharacteristicValue } from './index';

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
