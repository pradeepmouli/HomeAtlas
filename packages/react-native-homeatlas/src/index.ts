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
 * Type guard for service type checking (T079)
 * 
 * Checks if a service matches a specific typed service interface based on its type UUID.
 * This provides runtime type safety by validating the service.type property.
 * 
 * @template T - The specific service interface type (e.g., LightbulbService)
 * @param service - The generic service object to check
 * @param serviceType - The expected service type identifier (e.g., 'HMServiceTypeLightbulb')
 * @returns True if the service type matches, narrowing the type to T
 * 
 * @example
 * ```typescript
 * import HomeAtlas, { isServiceType, LightbulbService } from 'react-native-homeatlas';
 * 
 * const homes = await HomeAtlas.getHomes();
 * const service = homes[0].accessories[0].services[0];
 * 
 * // Type guard with runtime validation
 * if (isServiceType<LightbulbService>(service, 'HMServiceTypeLightbulb')) {
 *   // TypeScript now knows service is LightbulbService
 *   const isOn = service.powerstate.value; // boolean type
 *   const brightness = service.brightness?.value; // number | undefined
 * }
 * ```
 */
export function isServiceType<T extends Service>(
  service: Service,
  serviceType: string
): service is T {
  return service.type === serviceType;
}

/**
 * @deprecated Use isServiceType() instead for runtime type safety
 * 
 * Legacy helper function for type-safe service casting.
 * This function performs an unsafe cast without runtime validation.
 * Use isServiceType() for proper runtime type checking.
 * 
 * @template T - The specific service interface type
 * @param service - The generic service object to cast
 * @returns The service cast to the specified type, or null
 */
export function getTypedService<T extends Service>(service: Service): T | null {
  return service as T;
}

export default HomeAtlasAPI;
