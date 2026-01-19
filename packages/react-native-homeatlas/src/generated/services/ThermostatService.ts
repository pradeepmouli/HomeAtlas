// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * ThermostatService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for Thermostat
 */
export interface ThermostatService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeThermostat';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Required characteristic: CurrentTemperature
   */
  readonly currenttemperature: Characteristic<number>;

  /**
   * Required characteristic: TargetTemperature
   */
  readonly targettemperature: Characteristic<number>;

  /**
   * Optional characteristic: CurrentRelativeHumidity
   */
  readonly currentrelativehumidity?: Characteristic<number>;

  /**
   * Optional characteristic: TargetRelativeHumidity
   */
  readonly targetrelativehumidity?: Characteristic<number>;
}
