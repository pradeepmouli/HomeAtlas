// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * SwitchService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Switch
 */
export interface SwitchService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeSwitch';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: PowerState
   */
  readonly powerstate: Characteristic<boolean>;
}
