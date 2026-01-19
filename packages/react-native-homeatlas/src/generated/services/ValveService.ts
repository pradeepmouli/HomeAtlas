// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * ValveService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Valve
 */
export interface ValveService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeValve';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: InUse
   */
  readonly inuse: Characteristic<number>;

  /**
   * Required characteristic: ValveType
   */
  readonly valvetype: Characteristic<number>;

  /**
   * Optional characteristic: IsConfigured
   */
  readonly isconfigured?: Characteristic<number>;

  /**
   * Optional characteristic: RemainingDuration
   */
  readonly remainingduration?: Characteristic<number>;

  /**
   * Optional characteristic: LabelIndex
   */
  readonly labelindex?: Characteristic<number>;

  /**
   * Optional characteristic: SetDuration
   */
  readonly setduration?: Characteristic<number>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;
}
