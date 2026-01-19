// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * SecuritySystemService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for SecuritySystem
 */
export interface SecuritySystemService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeSecuritySystem';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Optional characteristic: SecuritySystemAlarmType
   */
  readonly securitysystemalarmtype?: Characteristic<number>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;

  /**
   * Optional characteristic: StatusTampered
   */
  readonly statustampered?: Characteristic<number>;
}
