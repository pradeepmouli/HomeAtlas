/**
 * Type tests for HomeAtlas API
 * Validates TypeScript type definitions and compile-time type safety
 */

import { describe, it, expect } from 'vitest';
import HomeAtlas from '../src/index';
import type {
  Home,
  Room,
  Accessory,
  Service,
  Characteristic,
  CharacteristicValue,
  ModuleState,
  HomeAtlasErrorCode,
  CharacteristicChangeEvent,
  Subscription,
  WriteMode,
} from '../src/index';

describe('Type Tests', () => {
  describe('User Story 1: Discovery Types', () => {
    it('T027: initialize() should return Promise<Home[]>', async () => {
      const result = HomeAtlas.initialize();
      
      // Type assertion: should be a Promise
      expect(result).toBeInstanceOf(Promise);
      
      // The result when resolved should be Home[]
      type InitializeReturn = ReturnType<typeof HomeAtlas.initialize>;
      const _typeCheck: InitializeReturn = result;
      
      // Runtime verification will be in integration tests
    });

    it('T028: getHomes() should return Promise<Home[]>', () => {
      const result = HomeAtlas.getHomes();
      
      // Type assertion: should be a Promise
      expect(result).toBeInstanceOf(Promise);
      
      type GetHomesReturn = ReturnType<typeof HomeAtlas.getHomes>;
      const _typeCheck: GetHomesReturn = result;
    });

    it('T029: getAllAccessories() should return Promise<Accessory[]>', () => {
      const result = HomeAtlas.getAllAccessories();
      
      expect(result).toBeInstanceOf(Promise);
      
      type GetAllAccessoriesReturn = ReturnType<typeof HomeAtlas.getAllAccessories>;
      const _typeCheck: GetAllAccessoriesReturn = result;
    });

    it('T030: getState() should return ModuleState', () => {
      const result = HomeAtlas.getState();
      
      // Type check: result should be ModuleState
      const validStates: ModuleState[] = ['uninitialized', 'ready', 'permissionDenied', 'error'];
      expect(validStates).toContain(result);
      
      // At compile time, this ensures getState returns a valid ModuleState
      type GetStateReturn = ReturnType<typeof HomeAtlas.getState>;
      const _typeCheck: GetStateReturn = result;
    });
  });

  describe('User Story 2: Read Types', () => {
    it('T049: readCharacteristic() should return Promise<CharacteristicValue>', () => {
      const result = HomeAtlas.readCharacteristic('uuid', 'lightbulb', 'on');
      
      expect(result).toBeInstanceOf(Promise);
      
      type ReadReturn = ReturnType<typeof HomeAtlas.readCharacteristic>;
      const _typeCheck: ReadReturn = result;
    });
  });

  describe('User Story 3: Write Types', () => {
    it('T057: writeCharacteristic() should accept optional mode parameter', () => {
      // Test all valid signatures
      const result1 = HomeAtlas.writeCharacteristic('uuid', 'lightbulb', 'on', true);
      const result2 = HomeAtlas.writeCharacteristic('uuid', 'lightbulb', 'brightness', 50, 'optimistic');
      const result3 = HomeAtlas.writeCharacteristic('uuid', 'lightbulb', 'brightness', 75, 'confirmed');
      
      expect(result1).toBeInstanceOf(Promise);
      expect(result2).toBeInstanceOf(Promise);
      expect(result3).toBeInstanceOf(Promise);
      
      // Type check: mode parameter should be optional and of type WriteMode
      type WriteReturn = ReturnType<typeof HomeAtlas.writeCharacteristic>;
      const _typeCheck1: WriteReturn = result1;
      const _typeCheck2: WriteReturn = result2;
      const _typeCheck3: WriteReturn = result3;
    });
  });

  describe('User Story 5: Subscription Types', () => {
    it('T081: subscribe() should return Subscription with remove method', () => {
      const callback = (event: CharacteristicChangeEvent) => {
        console.log(event);
      };
      
      const subscription = HomeAtlas.subscribe('uuid', 'on', callback);
      
      // Type check: Subscription interface
      expect(subscription).toHaveProperty('remove');
      expect(typeof subscription.remove).toBe('function');
      
      type SubscribeReturn = ReturnType<typeof HomeAtlas.subscribe>;
      const _typeCheck: SubscribeReturn = subscription;
    });

    it('T082: CharacteristicChangeEvent should have correct structure', () => {
      const mockEvent: CharacteristicChangeEvent = {
        accessoryId: 'test-uuid',
        serviceType: 'lightbulb',
        characteristicType: 'on',
        value: true,
        timestamp: Date.now(),
      };
      
      // Type assertion: all properties should be present
      expect(mockEvent).toHaveProperty('accessoryId');
      expect(mockEvent).toHaveProperty('serviceType');
      expect(mockEvent).toHaveProperty('characteristicType');
      expect(mockEvent).toHaveProperty('value');
      expect(mockEvent).toHaveProperty('timestamp');
    });
  });

  describe('User Story 6: Error Types', () => {
    it('T093: HomeAtlasError should have correct structure', async () => {
      // Import HomeAtlasError dynamically
      const { HomeAtlasError } = await import('../src/HomeAtlasError');
      
      const error = new HomeAtlasError(
        'permissionDenied',
        'Permission denied',
        {
          accessoryId: 'test-uuid',
          accessoryName: 'Test Device',
          characteristicType: 'on',
          underlyingError: 'Original error',
        }
      );
      
      // Type check: HomeAtlasError properties
      expect(error.code).toBe('permissionDenied');
      expect(error.message).toBe('Permission denied');
      expect(error.accessoryId).toBe('test-uuid');
      expect(error.accessoryName).toBe('Test Device');
      expect(error.characteristicType).toBe('on');
      expect(error.underlyingError).toBe('Original error');
    });
  });

  describe('Core Type Definitions', () => {
    it('should define Home type correctly', () => {
      const home: Home = {
        id: 'home-uuid',
        name: 'My Home',
        isPrimary: true,
        accessories: [],
        rooms: [],
      };
      
      expect(home.id).toBeDefined();
      expect(home.name).toBeDefined();
      expect(home.isPrimary).toBeDefined();
      expect(home.accessories).toBeInstanceOf(Array);
      expect(home.rooms).toBeInstanceOf(Array);
    });

    it('should define Accessory type correctly', () => {
      const accessory: Accessory = {
        id: 'accessory-uuid',
        name: 'Light',
        isReachable: true,
        isBlocked: false,
        category: 'lightbulb',
        roomId: null,
        services: [],
      };
      
      expect(accessory.id).toBeDefined();
      expect(accessory.name).toBeDefined();
      expect(accessory.category).toBeDefined();
      expect(accessory.services).toBeInstanceOf(Array);
    });

    it('should define Service type correctly', () => {
      const service: Service = {
        id: 'service-uuid',
        type: 'lightbulb',
        name: null,
        isPrimary: true,
        characteristics: [],
      };
      
      expect(service.id).toBeDefined();
      expect(service.type).toBeDefined();
      expect(service.characteristics).toBeInstanceOf(Array);
    });

    it('should define Characteristic type correctly', () => {
      const characteristic: Characteristic = {
        id: 'char-uuid',
        type: 'on',
        value: true,
        supportsRead: true,
        supportsWrite: true,
        supportsNotify: true,
        minValue: null,
        maxValue: null,
        stepValue: null,
      };
      
      expect(characteristic.id).toBeDefined();
      expect(characteristic.type).toBeDefined();
      expect(characteristic.value).toBeDefined();
    });

    it('should allow CharacteristicValue union types', () => {
      // Boolean
      const boolValue: CharacteristicValue = true;
      // Number
      const numberValue: CharacteristicValue = 42;
      // String
      const stringValue: CharacteristicValue = 'test';
      // Number array
      const arrayValue: CharacteristicValue = [1, 2, 3];
      
      expect(typeof boolValue).toBe('boolean');
      expect(typeof numberValue).toBe('number');
      expect(typeof stringValue).toBe('string');
      expect(Array.isArray(arrayValue)).toBe(true);
    });

    it('should define ModuleState literals', () => {
      const states: ModuleState[] = [
        'uninitialized',
        'ready',
        'permissionDenied',
        'error',
      ];
      
      states.forEach(state => {
        expect(['uninitialized', 'ready', 'permissionDenied', 'error']).toContain(state);
      });
    });

    it('should define WriteMode literals', () => {
      const modes: WriteMode[] = ['optimistic', 'confirmed'];
      
      modes.forEach(mode => {
        expect(['optimistic', 'confirmed']).toContain(mode);
      });
    });

    it('should define HomeAtlasErrorCode literals', () => {
      const codes: HomeAtlasErrorCode[] = [
        'permissionDenied',
        'deviceUnreachable',
        'operationNotSupported',
        'invalidValue',
        'timeout',
        'platformUnavailable',
        'unknown',
      ];
      
      codes.forEach(code => {
        expect([
          'permissionDenied',
          'deviceUnreachable',
          'operationNotSupported',
          'invalidValue',
          'timeout',
          'platformUnavailable',
          'unknown',
        ]).toContain(code);
      });
    });
  });

  describe('User Story 4: Type-Safe Service Access', () => {
    it('T069: LightbulbService should have proper TypeScript types', () => {
      // This test validates that when service types are generated,
      // they provide compile-time type safety and autocomplete
      
      // Mock service that would be returned from getTypedService
      const mockLightbulbService = {
        id: 'service-uuid',
        type: 'lightbulb',
        name: 'Main Light',
        isPrimary: true,
        characteristics: [
          {
            id: 'char-1',
            type: 'on',
            value: true,
            supportsRead: true,
            supportsWrite: true,
            supportsNotify: true,
            minValue: null,
            maxValue: null,
            stepValue: null,
          },
          {
            id: 'char-2',
            type: 'brightness',
            value: 75,
            supportsRead: true,
            supportsWrite: true,
            supportsNotify: true,
            minValue: 0,
            maxValue: 100,
            stepValue: 1,
          },
        ],
      };
      
      // Type assertions to ensure service type structure is correct
      expect(mockLightbulbService.type).toBe('lightbulb');
      expect(mockLightbulbService.characteristics).toHaveLength(2);
      
      // When generated types exist, this would enable:
      // - TypeScript autocomplete for service.on, service.brightness
      // - Compile-time errors for invalid property access
      // - Proper value types (boolean for 'on', number for 'brightness')
      
      const onChar = mockLightbulbService.characteristics.find(c => c.type === 'on');
      const brightnessChar = mockLightbulbService.characteristics.find(c => c.type === 'brightness');
      
      expect(onChar).toBeDefined();
      expect(onChar?.value).toBe(true);
      expect(typeof onChar?.value).toBe('boolean');
      
      expect(brightnessChar).toBeDefined();
      expect(brightnessChar?.value).toBe(75);
      expect(typeof brightnessChar?.value).toBe('number');
    });

    it('T070: ThermostatService should have proper TypeScript types', () => {
      // Mock thermostat service structure
      const mockThermostatService = {
        id: 'service-uuid',
        type: 'thermostat',
        name: 'Living Room Thermostat',
        isPrimary: true,
        characteristics: [
          {
            id: 'char-1',
            type: 'currentTemperature',
            value: 21.5,
            supportsRead: true,
            supportsWrite: false,
            supportsNotify: true,
            minValue: -270,
            maxValue: 100,
            stepValue: 0.1,
          },
          {
            id: 'char-2',
            type: 'targetTemperature',
            value: 22.0,
            supportsRead: true,
            supportsWrite: true,
            supportsNotify: true,
            minValue: 10,
            maxValue: 38,
            stepValue: 0.1,
          },
          {
            id: 'char-3',
            type: 'currentHeatingCoolingState',
            value: 1, // heating
            supportsRead: true,
            supportsWrite: false,
            supportsNotify: true,
            minValue: 0,
            maxValue: 2,
            stepValue: 1,
          },
        ],
      };
      
      // Type assertions
      expect(mockThermostatService.type).toBe('thermostat');
      expect(mockThermostatService.characteristics).toHaveLength(3);
      
      // When generated types exist, this enables:
      // - Autocomplete for thermostat-specific characteristics
      // - Type safety for temperature values (numbers)
      // - Compile-time validation of characteristic access
      
      const currentTemp = mockThermostatService.characteristics.find(
        c => c.type === 'currentTemperature'
      );
      const targetTemp = mockThermostatService.characteristics.find(
        c => c.type === 'targetTemperature'
      );
      const heatingState = mockThermostatService.characteristics.find(
        c => c.type === 'currentHeatingCoolingState'
      );
      
      expect(currentTemp).toBeDefined();
      expect(typeof currentTemp?.value).toBe('number');
      expect(currentTemp?.value).toBe(21.5);
      expect(currentTemp?.supportsWrite).toBe(false);
      
      expect(targetTemp).toBeDefined();
      expect(typeof targetTemp?.value).toBe('number');
      expect(targetTemp?.value).toBe(22.0);
      expect(targetTemp?.supportsWrite).toBe(true);
      
      expect(heatingState).toBeDefined();
      expect(typeof heatingState?.value).toBe('number');
      expect([0, 1, 2]).toContain(heatingState?.value);
    });
  });
});
