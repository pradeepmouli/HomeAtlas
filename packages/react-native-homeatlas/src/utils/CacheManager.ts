/**
 * CacheManager utility for in-memory home structure storage (FR-002a)
 * @packageDocumentation
 */

import type { Home, Accessory } from '../types';

/**
 * CacheManager provides in-memory caching of home structure data.
 * 
 * Per FR-002a: Cache home structure data (homes, accessories, rooms, services)
 * in memory during app session. Cache is cleared on module reinitialization.
 */
export class CacheManager {
  private homes: Home[] | null = null;
  private accessoriesMap: Map<string, Accessory> | null = null;
  private lastUpdateTimestamp: number | null = null;

  /**
   * Store homes in cache.
   * 
   * @param homes - Array of homes to cache
   */
  setHomes(homes: Home[]): void {
    this.homes = homes;
    this.lastUpdateTimestamp = Date.now();
    
    // Build accessory lookup map for fast access
    this.accessoriesMap = new Map();
    for (const home of homes) {
      for (const accessory of home.accessories) {
        this.accessoriesMap.set(accessory.id, accessory);
      }
    }
  }

  /**
   * Get cached homes.
   * 
   * @returns Cached homes or null if not cached
   */
  getHomes(): Home[] | null {
    return this.homes;
  }

  /**
   * Get a specific home by ID.
   * 
   * @param homeId - Home UUID
   * @returns Home or null if not found
   */
  getHome(homeId: string): Home | null {
    if (!this.homes) {
      return null;
    }
    
    return this.homes.find(home => home.id === homeId) ?? null;
  }

  /**
   * Get all accessories across all homes.
   * 
   * @returns Array of all accessories or null if not cached
   */
  getAllAccessories(): Accessory[] | null {
    if (!this.accessoriesMap) {
      return null;
    }
    
    return Array.from(this.accessoriesMap.values());
  }

  /**
   * Get a specific accessory by ID.
   * 
   * @param accessoryId - Accessory UUID
   * @returns Accessory or null if not found
   */
  getAccessory(accessoryId: string): Accessory | null {
    if (!this.accessoriesMap) {
      return null;
    }
    
    return this.accessoriesMap.get(accessoryId) ?? null;
  }

  /**
   * Find an accessory by name (case-insensitive).
   * 
   * @param name - Accessory name
   * @returns First matching accessory or null if not found
   */
  findAccessoryByName(name: string): Accessory | null {
    if (!this.accessoriesMap) {
      return null;
    }
    
    const lowerName = name.toLowerCase();
    
    for (const accessory of this.accessoriesMap.values()) {
      if (accessory.name.toLowerCase() === lowerName) {
        return accessory;
      }
    }
    
    return null;
  }

  /**
   * Check if cache has data.
   * 
   * @returns true if cache is populated
   */
  isCached(): boolean {
    return this.homes !== null;
  }

  /**
   * Get timestamp of last cache update.
   * 
   * @returns Unix timestamp in milliseconds or null if never updated
   */
  getLastUpdateTimestamp(): number | null {
    return this.lastUpdateTimestamp;
  }

  /**
   * Clear all cached data.
   */
  clear(): void {
    this.homes = null;
    this.accessoriesMap = null;
    this.lastUpdateTimestamp = null;
  }
}
