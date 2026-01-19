// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * SpeakerService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Speaker
 */
export interface SpeakerService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeSpeaker';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Mute
   */
  readonly mute: Characteristic<boolean>;

  /**
   * Optional characteristic: Active
   */
  readonly active?: Characteristic<number>;

  /**
   * Optional characteristic: Volume
   */
  readonly volume?: Characteristic<number>;

  /**
   * Optional characteristic: VolumeControlType
   */
  readonly volumecontroltype?: Characteristic<number>;

  /**
   * Optional characteristic: VolumeSelector
   */
  readonly volumeselector?: Characteristic<number>;
}
