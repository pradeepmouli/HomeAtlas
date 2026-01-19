// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * OutletService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Outlet
 */
export interface OutletService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeOutlet';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: PowerState
   */
  readonly powerstate: Characteristic<boolean>;

  /**
   * Optional characteristic: OutletInUse
   */
  readonly outletinuse?: Characteristic<boolean>;
}
