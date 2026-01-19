// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * DoorbellService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Doorbell
 */
export interface DoorbellService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeDoorbell';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Optional characteristic: Brightness
   */
  readonly brightness?: Characteristic<number>;

  /**
   * Optional characteristic: Mute
   */
  readonly mute?: Characteristic<boolean>;

  /**
   * Optional characteristic: Volume
   */
  readonly volume?: Characteristic<number>;
}
