// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * TelevisionService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Television
 */
export interface TelevisionService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeTelevision';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: Active
   */
  readonly active: Characteristic<number>;

  /**
   * Required characteristic: ActiveIdentifier
   */
  readonly activeidentifier: Characteristic<number>;

  /**
   * Required characteristic: ConfiguredName
   */
  readonly configuredname: Characteristic<string>;

  /**
   * Required characteristic: RemoteKey
   */
  readonly remotekey: Characteristic<number>;

  /**
   * Optional characteristic: Brightness
   */
  readonly brightness?: Characteristic<number>;

  /**
   * Optional characteristic: ClosedCaptions
   */
  readonly closedcaptions?: Characteristic<number>;

  /**
   * Optional characteristic: CurrentMediaState
   */
  readonly currentmediastate?: Characteristic<number>;

  /**
   * Optional characteristic: TargetMediaState
   */
  readonly targetmediastate?: Characteristic<number>;

  /**
   * Optional characteristic: PictureMode
   */
  readonly picturemode?: Characteristic<number>;

  /**
   * Optional characteristic: PowerModeSelection
   */
  readonly powermodeselection?: Characteristic<number>;
}
