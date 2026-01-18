/**
 * DebugLogger utility for optional developer-facing logging (FR-013a)
 * @packageDocumentation
 */

/**
 * DebugLogger provides optional diagnostic logging that can be enabled
 * for troubleshooting.
 * 
 * Per FR-013a: Developer-facing debug logging with enable/disable toggle.
 */
export class DebugLogger {
  private static enabled = false;
  private static readonly prefix = '[HomeAtlas]';

  /**
   * Enable or disable debug logging.
   * 
   * @param enabled - Whether to enable debug logging
   */
  static setEnabled(enabled: boolean): void {
    this.enabled = enabled;
    if (enabled) {
      console.log(`${this.prefix} Debug logging enabled`);
    }
  }

  /**
   * Check if debug logging is enabled.
   * 
   * @returns true if enabled
   */
  static isEnabled(): boolean {
    return this.enabled;
  }

  /**
   * Log a debug message (only if enabled).
   * 
   * @param message - Message to log
   * @param data - Optional data to log
   */
  static log(message: string, data?: unknown): void {
    if (this.enabled) {
      if (data !== undefined) {
        console.log(`${this.prefix} ${message}`, data);
      } else {
        console.log(`${this.prefix} ${message}`);
      }
    }
  }

  /**
   * Log a warning message (only if enabled).
   * 
   * @param message - Message to log
   * @param data - Optional data to log
   */
  static warn(message: string, data?: unknown): void {
    if (this.enabled) {
      if (data !== undefined) {
        console.warn(`${this.prefix} ${message}`, data);
      } else {
        console.warn(`${this.prefix} ${message}`);
      }
    }
  }

  /**
   * Log an error message (only if enabled).
   * 
   * @param message - Message to log
   * @param error - Optional error object
   */
  static error(message: string, error?: unknown): void {
    if (this.enabled) {
      if (error !== undefined) {
        console.error(`${this.prefix} ${message}`, error);
      } else {
        console.error(`${this.prefix} ${message}`);
      }
    }
  }
}
