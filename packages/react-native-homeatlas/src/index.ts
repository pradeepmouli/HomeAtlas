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
export type { HomeAtlasError, HomeAtlasErrorCode } from './types/error';
export type { ModuleState } from './types/state';
export type { WriteMode } from './types/write';
export type { CharacteristicChangeEvent, Subscription } from './types/events';

// Export utilities (for advanced usage)
export { RetryHelper } from './utils/RetryHelper';
export { DebugLogger } from './utils/DebugLogger';
export { CacheManager } from './utils/CacheManager';

// Native module interface (for reference only)
export type { NativeHomeAtlas } from './NativeHomeAtlas';

// TODO: Implement main HomeAtlas API class
// This will be completed in Phase 3 after Swift module is implemented
