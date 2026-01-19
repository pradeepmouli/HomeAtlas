// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * LabelService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Label
 */
export interface LabelService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeLabel';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: LabelNamespace
   */
  readonly labelnamespace: Characteristic<number>;
}
