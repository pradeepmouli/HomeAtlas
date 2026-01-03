# Running the HomeAtlas Example Apps

This guide explains how to build and run the HomeAtlas example applications on macOS.

## Prerequisites

- **macOS** with HomeKit support (macOS 13+)
- **Xcode 16** or newer with Swift 6.0 toolchain
- **HomeKit setup**: You need at least one HomeKit home configured on your Mac (via the Home app)

## Available Example Apps

There are three example applications available:

### 1. SwiftUIExample (Recommended)
A minimal SwiftUI application demonstrating basic HomeAtlas integration.

**Features:**
- Discovers and lists HomeKit homes
- Shows accessories with reachability indicators
- Displays accessory details including services
- Warms accessory cache on launch for better performance

### 2. HomeAtlasApp
A standalone macOS app with the same functionality as SwiftUIExample.

### 3. Integration
A command-line integration example for cross-platform testing.

## Running the Examples

### Option 1: Run from the Root Package (Easiest)

From the repository root:

```bash
# Build the example
swift build --product HomeAtlasSwiftUIExample

# Run the example
swift run HomeAtlasSwiftUIExample
```

This will launch a SwiftUI window showing your HomeKit homes and accessories.

### Option 2: Run from Standalone SwiftUIExample Package

```bash
cd Examples/SwiftUIExample

# Build the example
swift build --product HomeAtlasSwiftUIExample

# Run the example
swift run HomeAtlasSwiftUIExample
```

### Option 3: Run from HomeAtlasApp Package

```bash
cd Examples/HomeAtlasApp

# Build the app
swift build --product HomeAtlasApp

# Run the app
swift run HomeAtlasApp
```

### Option 4: Open in Xcode (Best for Development)

For interactive development with SwiftUI previews:

```bash
# Open the root package
open Package.swift

# Or open a standalone example
cd Examples/SwiftUIExample
open Package.swift
```

In Xcode:
1. Select the example target (e.g., `HomeAtlasSwiftUIExample`)
2. Choose **"My Mac"** as the run destination
3. Click the Run button (⌘R)

## What to Expect

When you run the example app:

1. **Initial Discovery**: The app shows "Discovering HomeKit homes…" while it connects to HomeKit
2. **Home List**: Once ready, you'll see a list of your configured homes
3. **Accessories**: Each home section shows its accessories with:
   - Accessory name and category
   - Green/red dot indicating reachability status
4. **Details**: Click an accessory to view:
   - Metadata (name, room, category, reachability)
   - List of available services

## Troubleshooting

### "No HomeKit homes detected"
- Make sure you have at least one home configured in the Home app
- Grant the app HomeKit permissions when prompted
- Check System Settings > Privacy & Security > HomeKit

### "Invalid parameter not satisfying: bundleIdentifier" (Mac Catalyst)
- This occurs when selecting Mac Catalyst as the run destination
- **Solution**: Choose **"My Mac"** instead (not Mac Catalyst)
- For iOS/Catalyst: Create a proper Xcode app target with Info.plist

### "swift: command not found" on Linux
- These examples require macOS with HomeKit support
- They cannot run on Linux or other platforms

### Build Errors
- Ensure you have Xcode 16+ with Swift 6.0 toolchain
- Clean build folder: `swift package clean`
- Reset package dependencies: `swift package reset`

## Understanding the Code

### Entry Point
The app entry point is in `HomeAtlasSwiftUIExampleApp.swift`:
- Creates a `HomeKitManager` instance
- Waits for HomeKit discovery
- Warms up the accessory cache for performance

### Main View
`ContentView.swift` contains:
- Home and accessory listing logic
- Reachability indicators
- Accessory detail views
- Service enumeration

### Key Concepts Demonstrated
1. **Async/await HomeKit operations** with `@MainActor`
2. **Type-safe service access** via generated wrappers
3. **Cache management** for performance optimization
4. **SwiftUI integration** with HomeKit manager as `@StateObject`

## Next Steps

After running the example, try:
- Adding accessory detail views showing characteristics
- Reading/writing characteristic values
- Implementing snapshot export with `AtlasSnapshotEncoder`
- Exploring diagnostic events with `DiagnosticsLogger`

See the main [README](../../README.md) for more detailed usage examples.
