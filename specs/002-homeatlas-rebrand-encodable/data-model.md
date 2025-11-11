# Data Model: HomeAtlas Snapshot

This document captures the entities and fields included in the JSON snapshot produced by the export API. It reflects user value, not implementation details.

## Entities

### Home
- id: string (stable identifier if available)
- name: string
- rooms: [Room]
- zones: [Zone]
- metadata: object
  - createdAt?: string (ISO 8601)
  - updatedAt?: string (ISO 8601)

### Room
- id: string
- name: string
- accessories: [Accessory]

### Zone
- id: string
- name: string
- roomIds: [string]

### Accessory
- id: string
- name: string
- manufacturer?: string
- model?: string
- firmwareVersion?: string
- services: [Service]

### Service
- id: string
- name?: string
- serviceType: string (canonical service identifier)
- characteristics: [Characteristic]

### Characteristic
- id: string
- characteristicType: string (canonical characteristic identifier)
- displayName?: string
- unit?: string
- min?: number
- max?: number
- step?: number
- readable: boolean
- writable: boolean
- value?: any | null (present when readable; null if restricted/unreadable)
- reason?: string (present when value is null; e.g., "permission", "unavailable")

## Relationships
- Home has many Rooms and Zones.
- Zone references Rooms by id.
- Room has many Accessories.
- Accessory has many Services.
- Service has many Characteristics.

## Validation Rules
- Identifiers are non-empty strings.
- `serviceType` and `characteristicType` are canonical keys per schema.
- If `readable` is false, `value` MAY be omitted or null; if null, `reason` MUST be present.
- Collections are ordered deterministically per research ordering rules.

