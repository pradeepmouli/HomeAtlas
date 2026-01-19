// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * AirPurifierService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for AirPurifier
 */
export interface AirPurifierService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeAirPurifier';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: CurrentAirPurifierState
   */
  readonly currentairpurifierstate: Characteristic<number>;

  /**
   * Required characteristic: TargetAirPurifierState
   */
  readonly targetairpurifierstate: Characteristic<number>;

  /**
   * Optional characteristic: LockPhysicalControls
   */
  readonly lockphysicalcontrols?: Characteristic<number>;

  /**
   * Optional characteristic: RotationSpeed
   */
  readonly rotationspeed?: Characteristic<number>;

  /**
   * Optional characteristic: SwingMode
   */
  readonly swingmode?: Characteristic<number>;
}
