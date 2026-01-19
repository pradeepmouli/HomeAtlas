// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * SlatsService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Slats
 */
export interface SlatsService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeSlats';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentSlatState
   */
  readonly currentslatstate: Characteristic<number>;

  /**
   * Required characteristic: SlatType
   */
  readonly slattype: Characteristic<number>;

  /**
   * Optional characteristic: SwingMode
   */
  readonly swingmode?: Characteristic<number>;
}
