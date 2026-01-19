// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * ContactSensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for ContactSensor
 */
export interface ContactSensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeContactSensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Optional characteristic: StatusActive
   */
  readonly statusactive?: Characteristic<boolean>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;

  /**
   * Optional characteristic: StatusLowBattery
   */
  readonly statuslowbattery?: Characteristic<number>;

  /**
   * Optional characteristic: StatusTampered
   */
  readonly statustampered?: Characteristic<number>;
}
