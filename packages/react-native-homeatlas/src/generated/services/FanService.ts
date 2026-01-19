// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * FanService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Fan
 */
export interface FanService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeFan';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Optional characteristic: CurrentFanState
   */
  readonly currentfanstate?: Characteristic<number>;

  /**
   * Optional characteristic: TargetFanState
   */
  readonly targetfanstate?: Characteristic<number>;

  /**
   * Optional characteristic: LockPhysicalControls
   */
  readonly lockphysicalcontrols?: Characteristic<number>;

  /**
   * Optional characteristic: RotationDirection
   */
  readonly rotationdirection?: Characteristic<number>;

  /**
   * Optional characteristic: RotationSpeed
   */
  readonly rotationspeed?: Characteristic<number>;

  /**
   * Optional characteristic: SwingMode
   */
  readonly swingmode?: Characteristic<number>;
}
