// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * WindowCoveringService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for WindowCovering
 */
export interface WindowCoveringService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeWindowCovering';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentPosition
   */
  readonly currentposition: Characteristic<number>;

  /**
   * Required characteristic: PositionState
   */
  readonly positionstate: Characteristic<number>;

  /**
   * Required characteristic: TargetPosition
   */
  readonly targetposition: Characteristic<number>;

  /**
   * Optional characteristic: ObstructionDetected
   */
  readonly obstructiondetected?: Characteristic<boolean>;

  /**
   * Optional characteristic: HoldPosition
   */
  readonly holdposition?: Characteristic<boolean>;
}
