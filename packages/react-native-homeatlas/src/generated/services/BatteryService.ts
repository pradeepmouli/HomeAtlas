// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * BatteryService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Battery
 */
export interface BatteryService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeBattery';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: StatusLowBattery
   */
  readonly statuslowbattery: Characteristic<number>;

  /**
   * Optional characteristic: BatteryLevel
   */
  readonly batterylevel?: Characteristic<number>;

  /**
   * Optional characteristic: ChargingState
   */
  readonly chargingstate?: Characteristic<number>;
}
