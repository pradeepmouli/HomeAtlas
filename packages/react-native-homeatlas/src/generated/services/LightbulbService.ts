// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * LightbulbService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Lightbulb
 */
export interface LightbulbService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeLightbulb';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: PowerState
   */
  readonly powerstate: Characteristic<boolean>;

  /**
   * Optional characteristic: Brightness
   */
  readonly brightness?: Characteristic<number>;

  /**
   * Optional characteristic: ColorTemperature
   */
  readonly colortemperature?: Characteristic<number>;

  /**
   * Optional characteristic: Hue
   */
  readonly hue?: Characteristic<number>;

  /**
   * Optional characteristic: Saturation
   */
  readonly saturation?: Characteristic<number>;
}
