# Quickstart: react-native-homeatlas

Get started with HomeAtlas TypeScript bindings for React Native and Expo.

## Prerequisites

- iOS 18+ device (HomeKit is not available on simulator)
- React Native 0.73+ or Expo SDK 50+
- Physical HomeKit accessories for testing

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

## Basic Usage

### Initialize and Discover Devices

```typescript
import HomeAtlas from 'react-native-homeatlas';

async function discoverDevices() {
  try {
    // Initialize - prompts for HomeKit permission
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

async function toggleLight(accessoryId: string) {
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
}

async function setBrightness(accessoryId: string, level: number) {
  // Set brightness (0-100)
  await HomeAtlas.writeCharacteristic(
    accessoryId,
    'lightbulb',
    'brightness',
    level
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
      console.log(`Temperature changed: ${event.value}°C`);
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
    const homeError = error as HomeAtlasError;

    switch (homeError.code) {
      case 'deviceUnreachable':
        console.error(`${homeError.accessoryName} is offline`);
        break;
      case 'invalidValue':
        console.error('Invalid value provided');
        break;
      default:
        console.error(`Error: ${homeError.message}`);
    }
  }
}
```

## React Hook Example

```typescript
import { useState, useEffect } from 'react';
import HomeAtlas, { Home, Accessory } from 'react-native-homeatlas';

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

## Troubleshooting

### "HomeKit is only available on iOS"

HomeAtlas requires a physical iOS device. The iOS Simulator does not support HomeKit.

### "Please grant HomeKit access in Settings"

The user denied HomeKit permission. Direct them to Settings > Privacy > HomeKit to enable access for your app.

### Device shows as unreachable

1. Ensure the device is powered on
2. Check that the iOS device and HomeKit accessory are on the same network
3. Try moving closer to the accessory
4. Restart the accessory

## Next Steps

- See [API Reference](./contracts/api.ts) for complete API documentation
- See [Data Model](./data-model.md) for entity structure details
- See [Examples/ReactNativeExample](../../Examples/ReactNativeExample) for a complete sample app
