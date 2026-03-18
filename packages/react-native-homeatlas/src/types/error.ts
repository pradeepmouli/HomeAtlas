/**
 * Error type definitions
 * @packageDocumentation
 */

import type { UUID } from './index';

/**
 * Error codes for HomeAtlas operations.
 */
export type HomeAtlasErrorCode =
  | 'permissionDenied'
  | 'deviceUnreachable'
  | 'operationNotSupported'
  | 'invalidValue'
  | 'timeout'
  | 'platformUnavailable'
  | 'unknown';

/**
 * Structured error with context for debugging.
 */
export interface HomeAtlasError extends Error {
  /** Error classification */
  readonly code: HomeAtlasErrorCode;
  /** Human-readable description */
  readonly message: string;
  /** Related accessory UUID (if applicable) */
  readonly accessoryId: UUID | null;
  /** Accessory name for display (if applicable) */
  readonly accessoryName: string | null;
  /** Related characteristic type (if applicable) */
  readonly characteristicType: string | null;
  /** Original error message from HomeKit */
  readonly underlyingError: string | null;
}
