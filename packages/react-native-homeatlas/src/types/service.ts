/**
 * Service type definitions
 * @packageDocumentation
 */

import type { UUID } from './index';
import type { Characteristic } from './characteristic';

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
