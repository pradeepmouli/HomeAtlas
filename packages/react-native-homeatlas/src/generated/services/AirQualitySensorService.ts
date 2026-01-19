// This file is auto-generated. Do not edit manually.
// Generated: 2026-01-19T01:55:51Z
// Generator: HomeKitServiceGenerator (TypeScript)

/**
 * AirQualitySensorService interface
 * Auto-generated from HomeKit catalog
 */

import { Service, Characteristic } from '../../types/service';

/**
 * Service interface for AirQualitySensor
 */
export interface AirQualitySensorService extends Service {
  /** Service type identifier */
  readonly type: 'HMServiceTypeAirQualitySensor';
  /** Service characteristics */
  readonly characteristics: Characteristic[];

  /**
   * Optional characteristic: NitrogenDioxideDensity
   */
  readonly nitrogendioxidedensity?: Characteristic<number>;

  /**
   * Optional characteristic: OzoneDensity
   */
  readonly ozonedensity?: Characteristic<number>;

  /**
   * Optional characteristic: PM10Density
   */
  readonly pm10density?: Characteristic<number>;

  /**
   * Optional characteristic: PM2_5Density
   */
  readonly pm25density?: Characteristic<number>;

  /**
   * Optional characteristic: SulphurDioxideDensity
   */
  readonly sulphurdioxidedensity?: Characteristic<number>;

  /**
   * Optional characteristic: VolatileOrganicCompoundDensity
   */
  readonly volatileorganiccompounddensity?: Characteristic<number>;

  /**
   * Optional characteristic: StatusActive
   */
  readonly statusactive?: Characteristic<boolean>;

  /**
   * Optional characteristic: StatusFault
   */
  readonly statusfault?: Characteristic<number>;

  /**
   * Optional characteristic: StatusLowBattery
   */
  readonly statuslowbattery?: Characteristic<number>;

  /**
   * Optional characteristic: StatusTampered
   */
  readonly statustampered?: Characteristic<number>;
}
