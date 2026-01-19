// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * HumiditySensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for HumiditySensor
 */
export interface HumiditySensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeHumiditySensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentRelativeHumidity
   */
  readonly currentrelativehumidity: Characteristic<number>;

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
