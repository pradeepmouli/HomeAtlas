// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * HeaterCoolerService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for HeaterCooler
 */
export interface HeaterCoolerService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeHeaterCooler';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: CurrentHeaterCoolerState
   */
  readonly currentheatercoolerstate: Characteristic<number>;

  /**
   * Required characteristic: TargetHeaterCoolerState
   */
  readonly targetheatercoolerstate: Characteristic<number>;

  /**
   * Required characteristic: CurrentTemperature
   */
  readonly currenttemperature: Characteristic<number>;

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
