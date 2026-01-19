// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * WiFiSatelliteService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for WiFiSatellite
 */
export interface WiFiSatelliteService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeWiFiSatellite';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: WiFiSatelliteStatus
   */
  readonly wifisatellitestatus: Characteristic<number>;
}
