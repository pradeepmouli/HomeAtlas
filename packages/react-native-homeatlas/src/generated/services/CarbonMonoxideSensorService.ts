// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * CarbonMonoxideSensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for CarbonMonoxideSensor
 */
export interface CarbonMonoxideSensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeCarbonMonoxideSensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CarbonMonoxideDetected
   */
  readonly carbonmonoxidedetected: Characteristic<number>;

  /**
   * Optional characteristic: CarbonMonoxideLevel
   */
  readonly carbonmonoxidelevel?: Characteristic<number>;

  /**
   * Optional characteristic: CarbonMonoxidePeakLevel
   */
  readonly carbonmonoxidepeaklevel?: Characteristic<number>;

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
