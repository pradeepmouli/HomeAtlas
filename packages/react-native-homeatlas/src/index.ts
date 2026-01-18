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

// Export main API as default
export { default } from './HomeAtlasAPI';
