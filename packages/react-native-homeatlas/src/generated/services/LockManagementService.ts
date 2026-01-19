// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * LockManagementService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for LockManagement
 */
export interface LockManagementService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeLockManagement';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Version
   */
  readonly version: Characteristic<string>;

  /**
   * Optional characteristic: AudioFeedback
   */
  readonly audiofeedback?: Characteristic<boolean>;

  /**
   * Optional characteristic: CurrentDoorState
   */
  readonly currentdoorstate?: Characteristic<number>;

  /**
   * Optional characteristic: Logs
   */
  readonly logs?: Characteristic<number[]>;

  /**
   * Optional characteristic: MotionDetected
   */
  readonly motiondetected?: Characteristic<boolean>;
}
