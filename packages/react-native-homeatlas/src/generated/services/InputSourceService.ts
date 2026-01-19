// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * InputSourceService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for InputSource
 */
export interface InputSourceService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeInputSource';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: ConfiguredName
   */
  readonly configuredname: Characteristic<string>;

  /**
   * Required characteristic: InputSourceType
   */
  readonly inputsourcetype: Characteristic<number>;

  /**
   * Required characteristic: IsConfigured
   */
  readonly isconfigured: Characteristic<number>;

  /**
   * Required characteristic: CurrentVisibilityState
   */
  readonly currentvisibilitystate: Characteristic<number>;

  /**
   * Optional characteristic: Identifier
   */
  readonly identifier?: Characteristic<number>;

  /**
   * Optional characteristic: InputDeviceType
   */
  readonly inputdevicetype?: Characteristic<number>;

  /**
   * Optional characteristic: TargetVisibilityState
   */
  readonly targetvisibilitystate?: Characteristic<number>;
}
