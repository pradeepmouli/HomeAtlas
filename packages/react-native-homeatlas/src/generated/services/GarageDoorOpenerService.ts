// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * GarageDoorOpenerService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for GarageDoorOpener
 */
export interface GarageDoorOpenerService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeGarageDoorOpener';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentDoorState
   */
  readonly currentdoorstate: Characteristic<number>;

  /**
   * Required characteristic: TargetDoorState
   */
  readonly targetdoorstate: Characteristic<number>;

  /**
   * Required characteristic: ObstructionDetected
   */
  readonly obstructiondetected: Characteristic<boolean>;
}
