/**
 * Base TypeScript types for react-native-homeatlas
 * @packageDocumentation
 */

/** Possible characteristic value types */
export type CharacteristicValue = boolean | number | string | number[];

/** UUID string format */
export type UUID = string;

// Re-export all types from submodules
export type { Home, Room } from './home';
export type { Accessory, AccessoryCategory } from './accessory';
export type { Service } from './service';
export type { Characteristic } from './characteristic';
export type { HomeAtlasError, HomeAtlasErrorCode } from './error';
export type { ModuleState } from './state';
export type { WriteMode } from './write';
export type { CharacteristicChangeEvent, Subscription } from './events';
