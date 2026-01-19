// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * TemperatureSensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for TemperatureSensor
 */
export interface TemperatureSensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeTemperatureSensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentTemperature
   */
  readonly currenttemperature: Characteristic<number>;

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
