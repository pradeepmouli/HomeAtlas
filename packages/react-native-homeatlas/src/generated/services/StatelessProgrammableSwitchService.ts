// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * StatelessProgrammableSwitchService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for StatelessProgrammableSwitch
 */
export interface StatelessProgrammableSwitchService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeStatelessProgrammableSwitch';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Optional characteristic: LabelIndex
   */
  readonly labelindex?: Characteristic<number>;
}
