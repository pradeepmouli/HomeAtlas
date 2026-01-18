/**
 * Module state type definitions
 * @packageDocumentation
 */

/**
 * Module state enumeration (FR-001a).
 * Represents the current initialization and permission state of the module.
 */
export type ModuleState =
  | 'uninitialized'   // Module has not been initialized yet
  | 'ready'           // Module is initialized and ready for operations
  | 'permissionDenied' // HomeKit permission was denied by user
  | 'error';          // An error occurred during initialization
