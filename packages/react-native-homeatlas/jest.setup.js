// Jest setup file
// Mock React Native modules
global.__DEV__ = true;

// Mock NativeModules completely without requiring react-native
jest.mock('react-native', () => ({
  NativeModules: {
    HomeAtlas: {
      initialize: jest.fn(),
      isReady: jest.fn(),
      getState: jest.fn(),
      getHomes: jest.fn(),
      getHome: jest.fn(),
      getAllAccessories: jest.fn(),
      getAccessory: jest.fn(),
      findAccessoryByName: jest.fn(),
      refresh: jest.fn(),
      readCharacteristic: jest.fn(),
      writeCharacteristic: jest.fn(),
      identify: jest.fn(),
      subscribe: jest.fn(),
      unsubscribe: jest.fn(),
      unsubscribeAll: jest.fn(),
      setDebugLoggingEnabled: jest.fn(),
    },
  },
  NativeEventEmitter: class MockEventEmitter {
    addListener = jest.fn(() => ({
      remove: jest.fn(),
    }));
    removeAllListeners = jest.fn();
    removeSubscription = jest.fn();
  },
  Platform: {
    OS: 'ios',
    Version: 17,
    select: jest.fn((obj) => obj.ios),
  },
}));

// Suppress console warnings in tests
const originalWarn = console.warn;
const originalError = console.error;

beforeAll(() => {
  console.warn = jest.fn((message) => {
    // Suppress specific warnings
    if (
      message.includes('Native module') ||
      message.includes('EventEmitter')
    ) {
      return;
    }
    originalWarn(message);
  });
  
  console.error = jest.fn((message) => {
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
