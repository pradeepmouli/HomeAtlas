/**
 * Accessory type definitions
 * @packageDocumentation
 */

import type { UUID } from './index';
import type { Service } from './service';

/**
 * HomeKit accessory category enumeration as exposed in the HomeAtlas TypeScript API.
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
