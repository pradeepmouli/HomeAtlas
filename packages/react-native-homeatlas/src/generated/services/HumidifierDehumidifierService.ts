// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * HumidifierDehumidifierService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for HumidifierDehumidifier
 */
export interface HumidifierDehumidifierService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeHumidifierDehumidifier';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: CurrentHumidifierDehumidifierState
   */
  readonly currenthumidifierdehumidifierstate: Characteristic<number>;

  /**
   * Required characteristic: TargetHumidifierDehumidifierState
   */
  readonly targethumidifierdehumidifierstate: Characteristic<number>;

  /**
   * Required characteristic: CurrentRelativeHumidity
   */
  readonly currentrelativehumidity: Characteristic<number>;

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
