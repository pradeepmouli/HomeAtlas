/**
 * HomeAtlas Error class for structured error handling
 * @packageDocumentation
 */

import type { UUID, HomeAtlasErrorCode } from './types';

/**
 * Structured error class for HomeAtlas operations.
 * 
 * Per FR-013: Provides semantic error codes, human-readable messages,
 * and contextual metadata for debugging.
 */
export class HomeAtlasError extends Error {
  public readonly code: HomeAtlasErrorCode;
  public readonly accessoryId: UUID | null;
  public readonly accessoryName: string | null;
  public readonly characteristicType: string | null;
  public readonly underlyingError: string | null;

  constructor(
    code: HomeAtlasErrorCode,
    message: string,
    context: {
      accessoryId?: UUID;
      accessoryName?: string;
      characteristicType?: string;
      underlyingError?: string;
    } = {}
  ) {
    super(message);
    this.name = 'HomeAtlasError';
    this.code = code;
    this.accessoryId = context.accessoryId ?? null;
    this.accessoryName = context.accessoryName ?? null;
    this.characteristicType = context.characteristicType ?? null;
    this.underlyingError = context.underlyingError ?? null;

    // Maintains proper stack trace for where error was thrown (only available on V8)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, HomeAtlasError);
    }
  }

  /**
   * Create a permission denied error.
   */
  static permissionDenied(message?: string): HomeAtlasError {
    return new HomeAtlasError(
      'permissionDenied',
      message ?? 'HomeKit permission denied. Please grant access in Settings.'
    );
  }

  /**
   * Create a device unreachable error.
   */
  static deviceUnreachable(
    accessoryName?: string,
    accessoryId?: UUID
  ): HomeAtlasError {
    const message = accessoryName
      ? `${accessoryName} is not responding`
      : 'Device is not responding';
    return new HomeAtlasError('deviceUnreachable', message, {
      accessoryId,
      accessoryName,
    });
  }

  /**
   * Create an operation not supported error.
   */
  static operationNotSupported(message: string): HomeAtlasError {
    return new HomeAtlasError('operationNotSupported', message);
  }

  /**
   * Create an invalid value error.
   */
  static invalidValue(message: string): HomeAtlasError {
    return new HomeAtlasError('invalidValue', message);
  }

  /**
   * Create a timeout error.
   */
  static timeout(message?: string): HomeAtlasError {
    return new HomeAtlasError(
      'timeout',
      message ?? 'Operation timed out'
    );
  }

  /**
   * Create a platform unavailable error.
   */
  static platformUnavailable(): HomeAtlasError {
    return new HomeAtlasError(
      'platformUnavailable',
      'HomeKit is only available on iOS'
    );
  }

  /**
   * Create an unknown error.
   */
  static unknown(message: string, underlyingError?: string): HomeAtlasError {
    return new HomeAtlasError('unknown', message, { underlyingError });
  }

  /**
   * Convert a native module error to a HomeAtlasError.
   */
  static fromNativeError(error: any): HomeAtlasError {
    if (error && typeof error === 'object') {
      const code = error.code as HomeAtlasErrorCode | undefined;
      const message = error.message || error.description || 'Unknown error';
      
      if (code && isValidErrorCode(code)) {
        return new HomeAtlasError(code, message, {
          accessoryId: error.accessoryId,
          accessoryName: error.accessoryName,
          characteristicType: error.characteristicType,
          underlyingError: error.underlyingError,
        });
      }
    }
    
    return HomeAtlasError.unknown(
      error?.message || error?.description || String(error)
    );
  }
}

/**
 * Type guard to check if an error is a HomeAtlasError.
 */
export function isHomeAtlasError(error: unknown): error is HomeAtlasError {
  return error instanceof HomeAtlasError;
}

/**
 * Check if a string is a valid HomeAtlasErrorCode.
 */
function isValidErrorCode(code: string): code is HomeAtlasErrorCode {
  return [
    'permissionDenied',
    'deviceUnreachable',
    'operationNotSupported',
    'invalidValue',
    'timeout',
    'platformUnavailable',
    'unknown',
  ].includes(code);
}
