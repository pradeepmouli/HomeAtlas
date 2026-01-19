// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * FilterMaintenanceService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for FilterMaintenance
 */
export interface FilterMaintenanceService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeFilterMaintenance';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: FilterChangeIndication
   */
  readonly filterchangeindication: Characteristic<number>;

  /**
   * Optional characteristic: FilterLifeLevel
   */
  readonly filterlifelevel?: Characteristic<number>;

  /**
   * Optional characteristic: FilterResetChangeIndication
   */
  readonly filterresetchangeindication?: Characteristic<number>;
}
