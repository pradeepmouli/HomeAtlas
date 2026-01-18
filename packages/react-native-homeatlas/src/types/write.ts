/**
 * Write mode type definitions
 * @packageDocumentation
 */

/**
 * Write mode for characteristic operations (FR-008a).
 * 
 * - 'optimistic': Returns immediately without waiting for device confirmation
 * - 'confirmed': Waits for device acknowledgment before returning
 */
export type WriteMode = 'optimistic' | 'confirmed';
