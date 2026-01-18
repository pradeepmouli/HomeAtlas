/**
 * Home and Room type definitions
 * @packageDocumentation
 */

import type { UUID } from './index';
import type { Accessory } from './accessory';

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
