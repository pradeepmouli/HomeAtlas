// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * IrrigationSystemService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for IrrigationSystem
 */
export interface IrrigationSystemService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeIrrigationSystem';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: ProgramMode
   */
  readonly programmode: Characteristic<number>;

  /**
   * Required characteristic: InUse
   */
  readonly inuse: Characteristic<number>;

  /**
   * Optional characteristic: RemainingDuration
   */
  readonly remainingduration?: Characteristic<number>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;
}
