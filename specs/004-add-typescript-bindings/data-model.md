# Data Model: TypeScript Bindings for HomeAtlas

**Date**: 2026-01-16
**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Entity Overview

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐       ┌──────────────────┐
│    Home     │ 1───* │  Accessory  │ 1───* │   Service   │ 1───* │  Characteristic  │
└─────────────┘       └─────────────┘       └─────────────┘       └──────────────────┘
      │                     │
      │ 1                   │
      ▼ *                   │
┌─────────────┐             │
│    Room     │ *─────────1 │
└─────────────┘
```

---

## Entity Definitions

### Home

Represents a HomeKit home (physical location with smart devices).

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `string` | Unique identifier (UUID) | Required, UUID format |
| `name` | `string` | User-assigned home name | Required, non-empty |
| `isPrimary` | `boolean` | Whether this is the primary home | Required |
| `accessories` | `Accessory[]` | Devices in this home | Required, may be empty |
| `rooms` | `Room[]` | Rooms in this home | Required, may be empty |

**State**: Immutable snapshot (refreshed on query)

---

### Room

Represents a room within a home.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `string` | Unique identifier (UUID) | Required, UUID format |
| `name` | `string` | User-assigned room name | Required, non-empty |

**State**: Immutable snapshot

---

### Accessory

Represents a physical or bridged HomeKit device.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `string` | Unique identifier (UUID) | Required, UUID format |
| `name` | `string` | User-assigned device name | Required, non-empty |
| `isReachable` | `boolean` | Whether device is currently accessible | Required |
| `isBlocked` | `boolean` | Whether device is blocked by user | Required |
| `category` | `AccessoryCategory` | Device category (light, thermostat, etc.) | Required |
| `roomId` | `string \| null` | Room assignment (if any) | Optional, UUID format |
| `services` | `Service[]` | Functional units of this device | Required, at least 1 |

**State**: Mutable via `isReachable` changes (push notifications)

---

### AccessoryCategory

Enumeration of HomeKit accessory categories.

| Value | Description |
|-------|-------------|
| `other` | Unknown or uncategorized |
| `bridge` | HomeKit bridge device |
| `fan` | Fan or air circulator |
| `garageDoorOpener` | Garage door controller |
| `lightbulb` | Light source |
| `doorLock` | Door lock |
| `outlet` | Power outlet |
| `switch` | Generic switch |
| `thermostat` | Climate control |
| `sensor` | Environmental sensor |
| `securitySystem` | Security system |
| `door` | Door sensor/controller |
| `window` | Window sensor/controller |
| `windowCovering` | Blinds, shades, curtains |
| `programmableSwitch` | Button or remote |
| `ipCamera` | IP camera |
| `videoDoorbell` | Video doorbell |
| `airPurifier` | Air purifier |
| `airHeater` | Heater |
| `airConditioner` | Air conditioner |
| `airHumidifier` | Humidifier |
| `airDehumidifier` | Dehumidifier |
| `sprinkler` | Sprinkler system |
| `faucet` | Smart faucet |
| `showerHead` | Smart shower |
| `television` | Smart TV |
| `router` | Network router |

---

### Service

Represents a functional unit of an accessory (e.g., a light's on/off capability).

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `string` | Unique identifier (UUID) | Required, UUID format |
| `type` | `string` | Service type identifier | Required, HomeKit service type |
| `name` | `string \| null` | User-assigned service name | Optional |
| `isPrimary` | `boolean` | Whether this is the primary service | Required |
| `characteristics` | `Characteristic[]` | Properties of this service | Required, at least 1 |

**Service Types**: ~100 types including:
- `lightbulb` - Light control
- `thermostat` - Temperature control
- `lockMechanism` - Lock control
- `motionSensor` - Motion detection
- `temperatureSensor` - Temperature reading
- `humiditySensor` - Humidity reading
- (Full list generated from HomeKit SDK)

---

### Characteristic

Represents a readable/writable property of a service.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `string` | Unique identifier (UUID) | Required, UUID format |
| `type` | `string` | Characteristic type identifier; must correspond to a HomeKit characteristic type constant (see `CharacteristicTypes` enum in tasks.md, T054) | Required |
| `value` | `CharacteristicValue` | Current value | Required for readable |
| `supportsRead` | `boolean` | Can be read | Required |
| `supportsWrite` | `boolean` | Can be written | Required |
| `supportsNotify` | `boolean` | Supports change notifications | Required |
| `minValue` | `number \| null` | Minimum allowed value | Optional, for numeric |
| `maxValue` | `number \| null` | Maximum allowed value | Optional, for numeric |
| `stepValue` | `number \| null` | Increment step | Optional, for numeric |

**CharacteristicValue**: `boolean | number | string | number[]`

**Characteristic Types**: ~200 types including:
- `on` - Boolean power state
- `brightness` - Integer 0-100
- `hue` - Float 0-360
- `saturation` - Float 0-100
- `currentTemperature` - Float (Celsius)
- `targetTemperature` - Float (Celsius)
- `lockCurrentState` - Enum (unsecured, secured, jammed, unknown)
- `lockTargetState` - Enum (unsecured, secured)
- (Full list generated from HomeKit SDK)

---

### HomeAtlasError

Structured error with context for debugging.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `code` | `HomeAtlasErrorCode` | Error classification | Required |
| `message` | `string` | Human-readable description | Required, non-empty |
| `accessoryId` | `string \| null` | Related accessory (if applicable) | Optional, UUID |
| `accessoryName` | `string \| null` | Accessory name for display | Optional |
| `characteristicType` | `string \| null` | Related characteristic | Optional |
| `underlyingError` | `string \| null` | Original error message | Optional |

**HomeAtlasErrorCode Enumeration**:

| Code | Description | User-Facing Message |
|------|-------------|---------------------|
| `permissionDenied` | HomeKit permission not granted | "Please grant HomeKit access in Settings" |
| `deviceUnreachable` | Accessory is offline | "Device is not responding" |
| `operationNotSupported` | Read/write not supported | "This property cannot be changed" |
| `invalidValue` | Value out of range or wrong type | "Invalid value provided" |
| `timeout` | Operation timed out | "Operation timed out" |
| `platformUnavailable` | Not running on iOS | "HomeKit is only available on iOS" |
| `unknown` | Unexpected error | "An unexpected error occurred" |

---

## Subscription Model

### CharacteristicSubscription

Represents an active notification subscription.

| Field | Type | Description |
|-------|------|-------------|
| `subscriptionId` | `string` | Unique subscription identifier |
| `accessoryId` | `string` | Target accessory |
| `characteristicType` | `string` | Target characteristic |

### CharacteristicChangeEvent

Event emitted when a subscribed characteristic changes.

| Field | Type | Description |
|-------|------|-------------|
| `accessoryId` | `string` | Source accessory |
| `serviceType` | `string` | Source service |
| `characteristicType` | `string` | Changed characteristic |
| `value` | `CharacteristicValue` | New value |
| `timestamp` | `number` | Unix timestamp (ms) |

---

## Type Safety Model

### Generated Service Types

For each HomeKit service type, a TypeScript interface is generated:

```typescript
// Example: Generated LightbulbService type
interface LightbulbService extends Service {
  type: 'lightbulb';
  /** Power state (required) */
  on: Characteristic<boolean>;
  /** Brightness 0-100 (optional) */
  brightness?: Characteristic<number>;
  /** Hue 0-360 (optional) */
  hue?: Characteristic<number>;
  /** Saturation 0-100 (optional) */
  saturation?: Characteristic<number>;
}
```

### Typed Characteristic Access

```typescript
// Generic characteristic with type parameter
interface Characteristic<T extends CharacteristicValue> {
  id: string;
  type: string;
  value: T;
  supportsRead: boolean;
  supportsWrite: boolean;
  supportsNotify: boolean;
  read(): Promise<T>;
  write(value: T): Promise<void>;
  subscribe(callback: (value: T) => void): Subscription;
}
```

---

## Data Flow

### Initialization Flow
```
App Start → initialize() → HomeKitManager.waitUntilReady() → Return Home[]
```

### Read Flow
```
readCharacteristic(id, type) → Find Accessory → Find Characteristic → characteristic.read() → Return value
```

### Write Flow
```
writeCharacteristic(id, type, value) → Validate value → characteristic.write(value) → Return success
```

### Subscription Flow
```
subscribe(id, type) → characteristic.setNotifications(true) → On change → Emit event → Callback
```
