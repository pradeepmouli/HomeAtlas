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

// Export generated types (Type-Safe Service Access - User Story 4)
export * from './generated';

// Export error class
export { HomeAtlasError, isHomeAtlasError } from './HomeAtlasError';

// Export utilities (for advanced usage)
export { RetryHelper } from './utils/RetryHelper';
export { DebugLogger } from './utils/DebugLogger';
export { CacheManager } from './utils/CacheManager';

// Native module interface (for reference only)
export type { NativeHomeAtlas } from './NativeHomeAtlas';

// Integrate RetryHelper with the main API and export it as default
import HomeAtlasAPI from './HomeAtlasAPI';
import { RetryHelper as InternalRetryHelper } from './utils/RetryHelper';

const defaultRetryHelper = new InternalRetryHelper();
(HomeAtlasAPI as any).retryHelper = defaultRetryHelper;

export default HomeAtlasAPI;
