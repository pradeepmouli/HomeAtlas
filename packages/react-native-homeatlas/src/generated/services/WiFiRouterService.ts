// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * WiFiRouterService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for WiFiRouter
 */
export interface WiFiRouterService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeWiFiRouter';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: ConfiguredName
   */
  readonly configuredname: Characteristic<string>;

  /**
   * Required characteristic: RouterStatus
   */
  readonly routerstatus: Characteristic<number>;

  /**
   * Required characteristic: WANStatusList
   */
  readonly wanstatuslist: Characteristic<number[]>;
}
