/**
 * Service type definitions
 * @packageDocumentation
 */

import type { UUID, CharacteristicValue } from './index';
import type { Characteristic } from './characteristic';

/**
 * Represents a functional unit of an accessory (e.g., lightbulb, thermostat).
 * Based on ServiceSnapshot from HomeAtlas encoding.
 * @template ServiceType - The specific service type identifier
 */
export interface Service<ServiceType extends string = string> {
  /** Unique identifier (UUID) */
  readonly id: UUID;
  /** Service type identifier (HomeKit UUID) */
  readonly type: ServiceType;
  /** User-assigned service name (optional) */
  readonly name?: Characteristic<string> | undefined;
}

