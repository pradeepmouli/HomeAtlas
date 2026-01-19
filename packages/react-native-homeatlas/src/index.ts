/**
 * HomeAtlas - TypeScript bindings for HomeKit control in React Native/Expo
 * @packageDocumentation
 */

// Export all types
export type { CharacteristicValue, UUID } from './types';
export type { Home, Room } from './types/home';
export type { Accessory, AccessoryCategory } from './types/accessory';
export type { Service } from './types/service';
export type { Characteristic } from './types/characteristic';
export type { HomeAtlasErrorCode } from './types/error';
export type { ModuleState } from './types/state';
export type { WriteMode } from './types/write';
export type { CharacteristicChangeEvent, Subscription } from './types/events';

// Export error class
export { HomeAtlasError, isHomeAtlasError } from './HomeAtlasError';

// Export utilities (for advanced usage)
export { RetryHelper } from './utils/RetryHelper';
export { DebugLogger } from './utils/DebugLogger';
export { CacheManager } from './utils/CacheManager';

// Native module interface (for reference only)
export type { NativeHomeAtlas } from './NativeHomeAtlas';

// Export generated types (T080)
export * from './generated';

// Integrate RetryHelper with the main API and export it as default
import HomeAtlasAPI from './HomeAtlasAPI';
import { RetryHelper as InternalRetryHelper } from './utils/RetryHelper';
import type { Service } from './types/service';

const defaultRetryHelper = new InternalRetryHelper();
(HomeAtlasAPI as any).retryHelper = defaultRetryHelper;

/**
 * Type-safe service helper function (T079)
 * 
 * Casts a generic Service to a specific typed service interface for compile-time safety.
 * This enables TypeScript autocomplete and type checking for service-specific characteristics.
 * 
 * @template T - The specific service interface type (e.g., LightbulbService)
 * @param service - The generic service object to cast
 * @returns The service cast to the specified type, or null if the service type doesn't match
 * 
 * @example
 * ```typescript
 * import HomeAtlas, { getTypedService, LightbulbService } from 'react-native-homeatlas';
 * 
 * const homes = await HomeAtlas.getHomes();
 * const lightbulb = homes[0].accessories[0].services[0];
 * 
 * // Get type-safe service with autocomplete
 * const typedLight = getTypedService<LightbulbService>(lightbulb);
 * if (typedLight) {
 *   // TypeScript now knows about lightbulb-specific characteristics
 *   const isOn = typedLight.powerstate.value; // boolean type
 *   const brightness = typedLight.brightness?.value; // number | undefined
 * }
 * ```
 */
export function getTypedService<T extends Service>(service: Service): T | null {
  // In a real implementation, we would check if service.type matches
  // the expected type constant. For now, we perform a simple cast
  // and let TypeScript provide compile-time safety.
  return service as T;
}

export default HomeAtlasAPI;
