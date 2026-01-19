// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * FaucetService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Faucet
 */
export interface FaucetService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeFaucet';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;
}
