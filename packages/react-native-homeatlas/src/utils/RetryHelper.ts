/**
 * RetryHelper utility for exponential backoff retry logic (FR-013b)
 * @packageDocumentation
 */

export interface RetryOptions {
  /** Maximum number of retry attempts (default: 3) */
  maxAttempts?: number;
  /** Initial delay in milliseconds (default: 1000) */
  initialDelayMs?: number;
  /** Exponential backoff multiplier (default: 2) */
  backoffMultiplier?: number;
  /** Maximum delay in milliseconds (default: 8000) */
  maxDelayMs?: number;
}

/**
 * RetryHelper provides exponential backoff retry logic for transient failures.
 * 
 * Per FR-013b: 1-3 attempts with increasing delays for network timeouts
 * and device temporarily unreachable errors.
 */
export class RetryHelper {
  private readonly maxAttempts: number;
  private readonly initialDelayMs: number;
  private readonly backoffMultiplier: number;
  private readonly maxDelayMs: number;

  constructor(options: RetryOptions = {}) {
    this.maxAttempts = options.maxAttempts ?? 3;
    this.initialDelayMs = options.initialDelayMs ?? 1000;
    this.backoffMultiplier = options.backoffMultiplier ?? 2;
    this.maxDelayMs = options.maxDelayMs ?? 8000;
  }

  /**
   * Execute an async function with retry logic.
   * 
   * @param fn - Function to execute
   * @param shouldRetry - Predicate to determine if error is retryable
   * @returns Promise resolving to function result
   * @throws Last error if all attempts fail
   */
  async execute<T>(
    fn: () => Promise<T>,
    shouldRetry: (error: unknown) => boolean = () => true
  ): Promise<T> {
    let lastError: unknown;
    
    for (let attempt = 1; attempt <= this.maxAttempts; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        
        // Don't retry if error is not retryable or last attempt
        if (!shouldRetry(error) || attempt === this.maxAttempts) {
          throw error;
        }
        
        // Calculate delay with exponential backoff
        const delay = Math.min(
          this.initialDelayMs * Math.pow(this.backoffMultiplier, attempt - 1),
          this.maxDelayMs
        );
        
        // Wait before next attempt
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    throw lastError;
  }

  /**
   * Check if an error is retryable based on common transient error patterns.
   * 
   * @param error - Error to check
   * @returns true if error appears to be transient
   */
  static isTransientError(error: unknown): boolean {
    if (!error || typeof error !== 'object') {
      return false;
    }
    
    const err = error as { code?: string; message?: string };
    
    // Retry on network timeouts and device unreachable
    return (
      err.code === 'timeout' ||
      err.code === 'deviceUnreachable' ||
      err.message?.includes('timeout') ||
      err.message?.includes('unreachable') ||
      err.message?.includes('network')
    );
  }
}
