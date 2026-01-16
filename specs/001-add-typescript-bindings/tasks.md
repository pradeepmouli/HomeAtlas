# Tasks: TypeScript Bindings for HomeAtlas

**Input**: Design documents from `/specs/001-add-typescript-bindings/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Tests**: Included per constitution TDD requirement.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Based on plan.md structure:
- **Package root**: `packages/react-native-homeatlas/`
- **TypeScript**: `packages/react-native-homeatlas/src/`
- **iOS native**: `packages/react-native-homeatlas/ios/`
- **Android stub**: `packages/react-native-homeatlas/android/`
- **Tests**: `packages/react-native-homeatlas/__tests__/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create package directory structure at packages/react-native-homeatlas/
- [ ] T002 Initialize package.json with name "react-native-homeatlas", dependencies (expo-modules-core, react-native), and scripts
- [ ] T003 [P] Create tsconfig.json with strict mode, ES2020 target, and React Native module resolution
- [ ] T004 [P] Create expo-module.config.json with module name "HomeAtlas" and iOS platform config
- [ ] T005 [P] Create app.plugin.js with NSHomeKitUsageDescription Info.plist modification
- [ ] T006 [P] Create iOS bridging header at packages/react-native-homeatlas/ios/HomeAtlas-Bridging-Header.h
- [ ] T007 [P] Create HomeAtlasModule.m Objective-C bridge header at packages/react-native-homeatlas/ios/HomeAtlasModule.m
- [ ] T008 Create Android stub module at packages/react-native-homeatlas/android/src/main/java/com/homeatlas/HomeAtlasModule.kt with platform unsupported error

**Checkpoint**: Package structure ready for implementation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core types and native module scaffold that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T009 [P] Create base TypeScript types at packages/react-native-homeatlas/src/types/index.ts (CharacteristicValue, UUID type aliases)
- [ ] T010 [P] Create Home type definition at packages/react-native-homeatlas/src/types/home.ts per contracts/api.ts
- [ ] T011 [P] Create Room type definition at packages/react-native-homeatlas/src/types/home.ts (same file as Home)
- [ ] T012 [P] Create Accessory type definition at packages/react-native-homeatlas/src/types/accessory.ts per contracts/api.ts
- [ ] T013 [P] Create AccessoryCategory type definition at packages/react-native-homeatlas/src/types/accessory.ts (same file)
- [ ] T014 [P] Create Service type definition at packages/react-native-homeatlas/src/types/service.ts per contracts/api.ts
- [ ] T015 [P] Create Characteristic type definition at packages/react-native-homeatlas/src/types/characteristic.ts per contracts/api.ts
- [ ] T016 [P] Create HomeAtlasError and HomeAtlasErrorCode types at packages/react-native-homeatlas/src/types/error.ts per contracts/api.ts
- [ ] T017 Create NativeHomeAtlas interface at packages/react-native-homeatlas/src/NativeHomeAtlas.ts defining native module methods
- [ ] T018 Create base HomeAtlasModule.swift skeleton at packages/react-native-homeatlas/ios/HomeAtlasModule.swift with Expo module definition
- [ ] T019 Create Serialization.swift at packages/react-native-homeatlas/ios/Serialization.swift with HomeKit→JSON conversion helpers
- [ ] T020 Create main index.ts at packages/react-native-homeatlas/src/index.ts re-exporting types and default HomeAtlas API

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Discover and List Smart Home Devices (Priority: P1) 🎯 MVP

**Goal**: Enable developers to initialize HomeAtlas, request permissions, and discover all HomeKit homes and accessories

**Independent Test**: Initialize module and verify homes/accessories are returned with correct structure

### Tests for User Story 1

- [ ] T021 [P] [US1] Write type test for initialize() return type in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T022 [P] [US1] Write type test for getHomes() return type in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T023 [P] [US1] Write type test for getAllAccessories() return type in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T024 [US1] Write unit test for Home/Accessory serialization in packages/react-native-homeatlas/__tests__/index.test.ts

### Implementation for User Story 1

- [ ] T025 [US1] Implement initialize() AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift bridging to HomeKitManager.waitUntilReady()
- [ ] T026 [US1] Implement isReady() Function in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T027 [US1] Implement getHomes() AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T028 [US1] Implement getHome(homeId) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T029 [US1] Implement getAllAccessories() AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T030 [US1] Implement getAccessory(accessoryId) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T031 [US1] Implement findAccessoryByName(name) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T032 [US1] Implement refresh() AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T033 [US1] Add serializeHome() helper in packages/react-native-homeatlas/ios/Serialization.swift converting HMHome to dictionary
- [ ] T034 [US1] Add serializeAccessory() helper in packages/react-native-homeatlas/ios/Serialization.swift converting HMAccessory to dictionary
- [ ] T035 [US1] Add serializeRoom() helper in packages/react-native-homeatlas/ios/Serialization.swift
- [ ] T036 [US1] Add serializeService() helper in packages/react-native-homeatlas/ios/Serialization.swift
- [ ] T037 [US1] Export initialize, isReady, getHomes, getHome, getAllAccessories, getAccessory, findAccessoryByName, refresh in packages/react-native-homeatlas/src/index.ts

**Checkpoint**: User Story 1 complete - developers can discover all HomeKit devices

---

## Phase 4: User Story 2 - Read Device State (Priority: P1)

**Goal**: Enable developers to read characteristic values from HomeKit accessories

**Independent Test**: Read a characteristic value and verify correct type is returned

### Tests for User Story 2

- [ ] T038 [P] [US2] Write type test for readCharacteristic() return type in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T039 [US2] Write unit test for characteristic value type mapping in packages/react-native-homeatlas/__tests__/index.test.ts

### Implementation for User Story 2

- [ ] T040 [US2] Implement readCharacteristic(accessoryId, serviceType, characteristicType) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T041 [US2] Add findCharacteristic() helper in packages/react-native-homeatlas/ios/HomeAtlasModule.swift to locate characteristic by accessory/service/type
- [ ] T042 [US2] Add serializeCharacteristicValue() helper in packages/react-native-homeatlas/ios/Serialization.swift handling Bool/Int/Double/String/Data
- [ ] T043 [US2] Export readCharacteristic in packages/react-native-homeatlas/src/index.ts

**Checkpoint**: User Story 2 complete - developers can read device states

---

## Phase 5: User Story 3 - Control Device State (Priority: P1)

**Goal**: Enable developers to write values to HomeKit accessories to control devices

**Independent Test**: Write a value to a writable characteristic and verify success/error handling

### Tests for User Story 3

- [ ] T044 [P] [US3] Write type test for writeCharacteristic() signature in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T045 [US3] Write unit test for value validation (range, type) in packages/react-native-homeatlas/__tests__/index.test.ts

### Implementation for User Story 3

- [ ] T046 [US3] Implement writeCharacteristic(accessoryId, serviceType, characteristicType, value) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T047 [US3] Add deserializeCharacteristicValue() helper in packages/react-native-homeatlas/ios/Serialization.swift converting JS value to HomeKit type
- [ ] T048 [US3] Add value validation in writeCharacteristic checking minValue/maxValue/stepValue constraints
- [ ] T049 [US3] Implement identify(accessoryId) AsyncFunction in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T050 [US3] Export writeCharacteristic, identify in packages/react-native-homeatlas/src/index.ts

**Checkpoint**: User Story 3 complete - developers can control smart home devices

---

## Phase 6: User Story 4 - Type-Safe Service Access (Priority: P2)

**Goal**: Provide TypeScript type definitions for all HomeKit service types with autocomplete

**Independent Test**: Import service types and verify TypeScript compiler provides autocomplete and catches invalid access

### Tests for User Story 4

- [ ] T051 [P] [US4] Write compile-time type tests for LightbulbService in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T052 [P] [US4] Write compile-time type tests for ThermostatService in packages/react-native-homeatlas/__tests__/types.test.ts

### Implementation for User Story 4

- [ ] T053 [US4] Create ServiceTypes enum at packages/react-native-homeatlas/src/types/service.ts with all HomeKit service type constants
- [ ] T054 [US4] Create CharacteristicTypes enum at packages/react-native-homeatlas/src/types/characteristic.ts with all characteristic type constants
- [ ] T055 [P] [US4] Create LightbulbService interface at packages/react-native-homeatlas/src/types/services/lightbulb.ts with typed on/brightness/hue/saturation
- [ ] T056 [P] [US4] Create ThermostatService interface at packages/react-native-homeatlas/src/types/services/thermostat.ts with typed temperature characteristics
- [ ] T057 [P] [US4] Create LockMechanismService interface at packages/react-native-homeatlas/src/types/services/lock.ts with typed lock state
- [ ] T058 [P] [US4] Create SwitchService interface at packages/react-native-homeatlas/src/types/services/switch.ts
- [ ] T059 [P] [US4] Create OutletService interface at packages/react-native-homeatlas/src/types/services/outlet.ts
- [ ] T060 [P] [US4] Create FanService interface at packages/react-native-homeatlas/src/types/services/fan.ts
- [ ] T061 [US4] Create services index at packages/react-native-homeatlas/src/types/services/index.ts re-exporting all service types
- [ ] T062 [US4] Add typed service helper getTypedService<T>() at packages/react-native-homeatlas/src/index.ts for compile-time safe service access

**Checkpoint**: User Story 4 complete - developers have full TypeScript autocomplete for services

---

## Phase 7: User Story 5 - Subscribe to Real-Time Updates (Priority: P2)

**Goal**: Enable developers to subscribe to characteristic change notifications

**Independent Test**: Subscribe to a characteristic, trigger change, verify callback fires with new value

### Tests for User Story 5

- [ ] T063 [P] [US5] Write type test for subscribe() signature and Subscription type in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T064 [P] [US5] Write type test for CharacteristicChangeEvent in packages/react-native-homeatlas/__tests__/types.test.ts

### Implementation for User Story 5

- [ ] T065 [US5] Create CharacteristicChangeEvent type at packages/react-native-homeatlas/src/types/events.ts per contracts/api.ts
- [ ] T066 [US5] Create Subscription interface at packages/react-native-homeatlas/src/types/events.ts per contracts/api.ts
- [ ] T067 [US5] Add Events("onCharacteristicChange") declaration in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T068 [US5] Implement subscribe(accessoryId, characteristicType) Function in packages/react-native-homeatlas/ios/HomeAtlasModule.swift using HMCharacteristic.enableNotification
- [ ] T069 [US5] Implement HMHomeManagerDelegate characteristic notification handler in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T070 [US5] Implement unsubscribeAll() Function in packages/react-native-homeatlas/ios/HomeAtlasModule.swift
- [ ] T071 [US5] Create TypeScript subscribe() wrapper at packages/react-native-homeatlas/src/index.ts using EventEmitter from expo-modules-core
- [ ] T072 [US5] Export subscribe, unsubscribeAll, CharacteristicChangeEvent, Subscription in packages/react-native-homeatlas/src/index.ts

**Checkpoint**: User Story 5 complete - developers can receive real-time device updates

---

## Phase 8: User Story 6 - Error Handling with Context (Priority: P2)

**Goal**: Provide structured errors with rich context for debugging

**Independent Test**: Trigger an error condition and verify error object contains code, message, and context

### Tests for User Story 6

- [ ] T073 [P] [US6] Write type test for HomeAtlasError structure in packages/react-native-homeatlas/__tests__/types.test.ts
- [ ] T074 [US6] Write unit test for error code mapping in packages/react-native-homeatlas/__tests__/index.test.ts

### Implementation for User Story 6

- [ ] T075 [US6] Create HomeAtlasError class at packages/react-native-homeatlas/src/HomeAtlasError.ts extending Error with code, accessoryId, accessoryName, characteristicType, underlyingError
- [ ] T076 [US6] Create error factory functions (permissionDenied, deviceUnreachable, etc.) at packages/react-native-homeatlas/src/HomeAtlasError.ts
- [ ] T077 [US6] Add createError() helper in packages/react-native-homeatlas/ios/HomeAtlasModule.swift mapping HomeKit errors to structured error dictionaries
- [ ] T078 [US6] Add error context enrichment to all AsyncFunctions in packages/react-native-homeatlas/ios/HomeAtlasModule.swift (accessory name, characteristic type)
- [ ] T079 [US6] Add platform check at module load in packages/react-native-homeatlas/ios/HomeAtlasModule.swift throwing platformUnavailable on non-iOS
- [ ] T080 [US6] Export HomeAtlasError, HomeAtlasErrorCode, isHomeAtlasError() type guard in packages/react-native-homeatlas/src/index.ts

**Checkpoint**: User Story 6 complete - developers have rich error diagnostics

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T081 [P] Add JSDoc comments to all exported functions in packages/react-native-homeatlas/src/index.ts
- [ ] T082 [P] Add inline documentation to HomeAtlasModule.swift
- [ ] T083 Create README.md at packages/react-native-homeatlas/README.md with installation and usage instructions
- [ ] T084 Validate package against quickstart.md scenarios
- [ ] T085 Add .npmignore at packages/react-native-homeatlas/.npmignore excluding tests and dev files
- [ ] T086 Run TypeScript compiler to verify all types compile without errors
- [ ] T087 Create Example app scaffold at Examples/ReactNativeExample/ demonstrating all user stories

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1, US2, US3 are P1 priority - complete first
  - US4, US5, US6 are P2 priority - can proceed after P1 stories
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational - Uses serialization from US1 but independently testable
- **User Story 3 (P1)**: Can start after Foundational - Uses serialization from US1 but independently testable
- **User Story 4 (P2)**: Can start after Foundational - Independent type definitions
- **User Story 5 (P2)**: Can start after Foundational - May use error types from US6 but independently testable
- **User Story 6 (P2)**: Can start after Foundational - No dependencies on other stories

### Within Each User Story

- Tests written FIRST and must FAIL before implementation
- Swift serialization helpers before AsyncFunction implementations
- AsyncFunction implementations before TypeScript exports
- Story complete before moving to next priority

### Parallel Opportunities

- T003-T008 can all run in parallel (different files)
- T009-T016 can all run in parallel (different type files)
- T021-T024 can run in parallel with T025-T037 if following TDD
- T055-T060 can all run in parallel (different service type files)
- T063-T064 can run in parallel
- T073, T081-T082 can run in parallel

---

## Parallel Example: Phase 2 (Foundational)

```bash
# Launch all type definitions together:
Task: "Create Home type definition at packages/react-native-homeatlas/src/types/home.ts"
Task: "Create Accessory type definition at packages/react-native-homeatlas/src/types/accessory.ts"
Task: "Create Service type definition at packages/react-native-homeatlas/src/types/service.ts"
Task: "Create Characteristic type definition at packages/react-native-homeatlas/src/types/characteristic.ts"
Task: "Create error types at packages/react-native-homeatlas/src/types/error.ts"
```

## Parallel Example: User Story 4 (Service Types)

```bash
# Launch all service type definitions together:
Task: "Create LightbulbService interface at packages/react-native-homeatlas/src/types/services/lightbulb.ts"
Task: "Create ThermostatService interface at packages/react-native-homeatlas/src/types/services/thermostat.ts"
Task: "Create LockMechanismService interface at packages/react-native-homeatlas/src/types/services/lock.ts"
Task: "Create SwitchService interface at packages/react-native-homeatlas/src/types/services/switch.ts"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Device Discovery)
4. **STOP and VALIDATE**: Test initialize(), getHomes(), getAllAccessories()
5. Deploy/demo if ready - developers can already see their HomeKit devices

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 (Discovery) → MVP ready - can show device list
3. Add User Story 2 (Read) → Can display device states
4. Add User Story 3 (Write) → Full control capability
5. Add User Story 4 (Types) → Better DX with autocomplete
6. Add User Story 5 (Subscribe) → Real-time updates
7. Add User Story 6 (Errors) → Production-ready error handling

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Stories 1 + 2 (Discovery + Read)
   - Developer B: User Stories 3 + 6 (Write + Errors)
   - Developer C: User Stories 4 + 5 (Types + Subscriptions)
3. Stories complete and integrate independently

---

## Summary

| Phase | Tasks | Parallel Opportunities |
|-------|-------|----------------------|
| Setup | 8 | 5 |
| Foundational | 12 | 8 |
| US1: Discovery | 17 | 4 |
| US2: Read | 6 | 2 |
| US3: Write | 7 | 2 |
| US4: Types | 12 | 8 |
| US5: Subscribe | 10 | 2 |
| US6: Errors | 8 | 2 |
| Polish | 7 | 2 |
| **Total** | **87** | **35** |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
