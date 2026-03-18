// Vitest setup file
import { vi } from 'vitest';

// Mock React Native modules
(global as any).__DEV__ = true;

// Mock NativeModules completely without requiring react-native
vi.mock('react-native', () => ({
  NativeModules: {
    HomeAtlas: {
      initialize: vi.fn(),
      isReady: vi.fn(),
      getState: vi.fn(),
      getHomes: vi.fn(),
      getHome: vi.fn(),
      getAllAccessories: vi.fn(),
      getAccessory: vi.fn(),
      findAccessoryByName: vi.fn(),
      refresh: vi.fn(),
      readCharacteristic: vi.fn(),
      writeCharacteristic: vi.fn(),
      identify: vi.fn(),
      subscribe: vi.fn(),
      unsubscribe: vi.fn(),
      unsubscribeAll: vi.fn(),
      setDebugLoggingEnabled: vi.fn(),
    },
  },
  NativeEventEmitter: class MockEventEmitter {
    addListener = vi.fn(() => ({
      remove: vi.fn(),
    }));
    removeAllListeners = vi.fn();
    removeSubscription = vi.fn();
  },
  Platform: {
    OS: 'ios',
    Version: 17,
    select: vi.fn((obj) => obj.ios),
  },
}));

// Suppress console warnings in tests
const originalWarn = console.warn;
const originalError = console.error;

beforeAll(() => {
  console.warn = vi.fn((message) => {
    // Suppress specific warnings
    if (
      message.includes('Native module') ||
      message.includes('EventEmitter')
    ) {
      return;
    }
    originalWarn(message);
  });
  
  console.error = vi.fn((message) => {
    // Suppress specific errors
    if (
      message.includes('Native module') ||
      message.includes('EventEmitter')
    ) {
      return;
    }
    originalError(message);
  });
});

afterAll(() => {
  console.warn = originalWarn;
  console.error = originalError;
});
