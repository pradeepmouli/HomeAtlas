# react-native-homeatlas

TypeScript bindings for HomeAtlas - HomeKit control for React Native and Expo.

## ⚠️ Platform Support

**iOS Only**: HomeKit is an Apple-exclusive framework. This package only works on iOS devices (iOS 18+). Android will throw a `platformUnavailable` error.

## Features

- 🏠 **Home Discovery**: Discover and list all HomeKit homes and accessories
- 📖 **Read Device State**: Read characteristic values from HomeKit devices
- ✍️ **Control Devices**: Write characteristic values to control smart home devices
- 🔔 **Real-time Updates**: Subscribe to characteristic change notifications
- 🛡️ **Type-Safe**: Full TypeScript support with type definitions
- ⚡ **Async/Await**: Modern async APIs throughout
- 🎯 **Error Handling**: Structured errors with semantic codes and context
- 🔄 **Write Modes**: Optimistic (immediate) and confirmed (wait for device) writes

## Installation

### Expo Projects

```bash
npx expo install react-native-homeatlas
```

### Bare React Native

```bash
npm install react-native-homeatlas
cd ios && pod install
```

## Configuration

### Expo (app.json)

```json
{
  "expo": {
    "plugins": [
      [
        "react-native-homeatlas",
        {
          "homeKitUsageDescription": "This app controls your smart home devices."
        }
      ]
    ]
  }
}
```

### Bare React Native (Info.plist)

Add to `ios/YourApp/Info.plist`:

```xml
<key>NSHomeKitUsageDescription</key>
<string>This app controls your smart home devices.</string>
```

## Quick Start

### Basic Usage

```typescript
import HomeAtlas from 'react-native-homeatlas';

// Initialize and discover devices
async function setupHomeKit() {
  try {
    // Prompts for HomeKit permission
    const homes = await HomeAtlas.initialize();
    
    console.log(`Found ${homes.length} homes`);
    for (const home of homes) {
      console.log(`Home: ${home.name}`);
      for (const accessory of home.accessories) {
        console.log(`  - ${accessory.name} (${accessory.category})`);
      }
    }
  } catch (error) {
    if (error.code === 'permissionDenied') {
      console.error('HomeKit permission denied');
    }
  }
}
```

### Control a Light

```typescript
import HomeAtlas from 'react-native-homeatlas';

async function controlLight(accessoryId: string) {
  // Read current state
  const isOn = await HomeAtlas.readCharacteristic(
    accessoryId,
    'lightbulb',
    'on'
  );
  
  // Toggle it
  await HomeAtlas.writeCharacteristic(
    accessoryId,
    'lightbulb',
    'on',
    !isOn
  );
  
  // Set brightness (0-100)
  await HomeAtlas.writeCharacteristic(
    accessoryId,
    'lightbulb',
    'brightness',
    75
  );
}
```

### Subscribe to Changes

```typescript
import HomeAtlas from 'react-native-homeatlas';

function watchTemperature(accessoryId: string) {
  const subscription = HomeAtlas.subscribe(
    accessoryId,
    'currentTemperature',
    (event) => {
      console.log(`Temperature: ${event.value}°C`);
    }
  );
  
  // Later: unsubscribe
  // subscription.remove();
}
```

### Error Handling

```typescript
import HomeAtlas, { HomeAtlasError } from 'react-native-homeatlas';

async function safeWrite(accessoryId: string, value: boolean) {
  try {
    await HomeAtlas.writeCharacteristic(
      accessoryId,
      'lightbulb',
      'on',
      value
    );
  } catch (error) {
    if (error instanceof HomeAtlasError) {
      switch (error.code) {
        case 'deviceUnreachable':
          console.error(`${error.accessoryName} is offline`);
          break;
        case 'invalidValue':
          console.error('Invalid value provided');
          break;
        default:
          console.error(`Error: ${error.message}`);
      }
    }
  }
}
```

## API Reference

### Initialization

#### `initialize(): Promise<Home[]>`

Initialize HomeAtlas and request HomeKit permissions. Must be called first.

**Returns**: Array of discovered homes

**Throws**: 
- `permissionDenied` if user denies HomeKit access
- `platformUnavailable` if not on iOS

#### `isReady(): boolean`

Check if HomeAtlas is ready (initialized with permissions).

#### `getState(): ModuleState`

Get current module state: `'uninitialized' | 'ready' | 'permissionDenied' | 'error'`

### Discovery

#### `getHomes(): Promise<Home[]>`

Get all discovered homes.

#### `getHome(homeId: string): Promise<Home | null>`

Get a specific home by UUID.

#### `getAllAccessories(): Promise<Accessory[]>`

Get all accessories across all homes.

#### `getAccessory(accessoryId: string): Promise<Accessory | null>`

Get a specific accessory by UUID.

#### `findAccessoryByName(name: string): Promise<Accessory | null>`

Find an accessory by name (case-insensitive).

### Characteristic Operations

#### `readCharacteristic(accessoryId: string, serviceType: string, characteristicType: string): Promise<CharacteristicValue>`

Read a characteristic value from a device.

**Parameters**:
- `accessoryId`: Accessory UUID
- `serviceType`: Service type (e.g., `'lightbulb'`, `'thermostat'`)
- `characteristicType`: Characteristic type (e.g., `'on'`, `'brightness'`)

**Returns**: The characteristic value (boolean, number, string, or number[])

**Throws**:
- `deviceUnreachable` if device is offline
- `operationNotSupported` if characteristic is not readable

#### `writeCharacteristic(accessoryId: string, serviceType: string, characteristicType: string, value: CharacteristicValue, mode?: 'optimistic' | 'confirmed'): Promise<void>`

Write a characteristic value to a device.

**Parameters**:
- `accessoryId`: Accessory UUID
- `serviceType`: Service type
- `characteristicType`: Characteristic type
- `value`: Value to write
- `mode`: Write mode (default: `'confirmed'`)
  - `'optimistic'`: Returns immediately, doesn't wait for device
  - `'confirmed'`: Waits for device acknowledgment

**Throws**:
- `deviceUnreachable` if device is offline
- `operationNotSupported` if characteristic is not writable
- `invalidValue` if value is out of range or wrong type

### Subscriptions

#### `subscribe(accessoryId: string, characteristicType: string, callback: (event: CharacteristicChangeEvent) => void, serviceType?: string): Subscription`

Subscribe to characteristic change notifications.

**Parameters**:
- `accessoryId`: Accessory UUID
- `characteristicType`: Characteristic type to monitor
- `callback`: Function called when value changes
- `serviceType`: Optional service type filter

**Returns**: Subscription handle with `remove()` method

#### `unsubscribeAll(): void`

Remove all active subscriptions.

### Utilities

#### `refresh(): Promise<void>`

Refresh the accessory cache to get updated device states.

#### `identify(accessoryId: string): Promise<void>`

Identify an accessory (causes device to flash/beep if supported).

#### `setDebugLoggingEnabled(enabled: boolean): void`

Enable or disable debug logging for troubleshooting.

## Common Service Types

| Service | Type String | Common Characteristics |
|---------|-------------|----------------------|
| Light | `lightbulb` | `on`, `brightness`, `hue`, `saturation` |
| Thermostat | `thermostat` | `currentTemperature`, `targetTemperature`, `heatingCoolingState` |
| Lock | `lockMechanism` | `lockCurrentState`, `lockTargetState` |
| Switch | `switch` | `on` |
| Outlet | `outlet` | `on`, `outletInUse` |
| Fan | `fanV2` | `active`, `rotationSpeed` |
| Garage Door | `garageDoorOpener` | `currentDoorState`, `targetDoorState` |

## Error Codes

| Code | Description |
|------|-------------|
| `permissionDenied` | HomeKit permission not granted |
| `deviceUnreachable` | Device is offline or not responding |
| `operationNotSupported` | Operation not supported by characteristic |
| `invalidValue` | Value out of range or wrong type |
| `timeout` | Operation timed out |
| `platformUnavailable` | Not running on iOS |
| `unknown` | Unexpected error |

## TypeScript Support

This package includes full TypeScript type definitions.

```typescript
import type { 
  Home, 
  Accessory, 
  Service, 
  Characteristic,
  AccessoryCategory,
  HomeAtlasError,
  CharacteristicChangeEvent
} from 'react-native-homeatlas';
```

## React Hook Example

```typescript
import { useState, useEffect } from 'react';
import HomeAtlas, { Home } from 'react-native-homeatlas';

export function useHomeAtlas() {
  const [homes, setHomes] = useState<Home[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let mounted = true;

    async function init() {
      try {
        const discoveredHomes = await HomeAtlas.initialize();
        if (mounted) {
          setHomes(discoveredHomes);
          setLoading(false);
        }
      } catch (e) {
        if (mounted) {
          setError(e as Error);
          setLoading(false);
        }
      }
    }

    init();

    return () => {
      mounted = false;
      HomeAtlas.unsubscribeAll();
    };
  }, []);

  return { homes, loading, error };
}
```

## Troubleshooting

### "HomeKit is only available on iOS"

HomeAtlas requires a physical iOS device. The iOS Simulator does not support HomeKit.

### "Please grant HomeKit access in Settings"

The user denied HomeKit permission. Direct them to **Settings > Privacy & Security > HomeKit** to enable access for your app.

### Device shows as unreachable

1. Ensure the device is powered on
2. Check that your iOS device and HomeKit accessory are on the same network
3. Try moving closer to the accessory
4. Restart the accessory

### "Module not initialized"

Call `HomeAtlas.initialize()` before any other operations.

## Requirements

- iOS 18.0+
- React Native 0.73+
- Expo SDK 50+ (for Expo projects)

## License

MIT

## Related Projects

- [HomeAtlas](https://github.com/pradeepmouli/HomeAtlas) - Swift HomeKit wrapper library

## Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/pradeepmouli/HomeAtlas).
