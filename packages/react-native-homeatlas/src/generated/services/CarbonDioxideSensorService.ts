// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * CarbonDioxideSensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for CarbonDioxideSensor
 */
export interface CarbonDioxideSensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeCarbonDioxideSensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CarbonDioxideDetected
   */
  readonly carbondioxidedetected: Characteristic<number>;

  /**
   * Optional characteristic: CarbonDioxideLevel
   */
  readonly carbondioxidelevel?: Characteristic<number>;

  /**
   * Optional characteristic: CarbonDioxidePeakLevel
   */
  readonly carbondioxidepeaklevel?: Characteristic<number>;

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
