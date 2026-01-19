// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * MicrophoneService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Microphone
 */
export interface MicrophoneService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeMicrophone';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Mute
   */
  readonly mute: Characteristic<boolean>;

  /**
   * Optional characteristic: Volume
   */
  readonly volume?: Characteristic<number>;
}
