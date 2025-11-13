# HomeAtlas SwiftUI Example

A minimal SwiftUI application demonstrating basic integration with the `HomeAtlas` library.

## Features
- Discovers HomeKit homes using `HomeKitManager`.
- Lists accessories per home with reachability indicator.
- Warms the accessory + service cache on launch for snappy UI.
- Gracefully degrades on platforms without HomeKit (shows stub message).

## Running

```bash
swift build --product HomeAtlasSwiftUIExample
swift run HomeAtlasSwiftUIExample
```

For interactive previews, open the package in Xcode 16 and run the `HomeAtlasSwiftUIExample` target.

### Important: Mac Catalyst and iOS

- This example is an SPM executable, which builds a desktop app on macOS but does not produce an iOS/Catalyst app bundle by itself.
- If you select a Mac Catalyst destination (UIKit on macOS) for this target, the process will fault early with an assertion like:
	`NSInternalInconsistencyException: Invalid parameter not satisfying: bundleIdentifier`.

How to run it successfully:

- macOS: Choose "My Mac" as the run destination. This uses the SwiftUI App lifecycle on macOS and launches normally.
- iOS / Mac Catalyst: Create a small Xcode app target (with an Info.plist and bundle identifier) and add this package as a dependency. Then embed the same SwiftUI views and run on Simulator/device or Catalyst.

## Code Overview
- `HomeAtlasSwiftUIExampleApp.swift`: App entry point; waits for HomeKit discovery.
- `ContentView.swift`: Renders homes and accessories with simple status indicators.

## Notes
- Accessory/service warming avoids on-demand wrapper creation cost during scrolling.
- Example keeps logic on the main actor per project guidelines.
- Extend `ContentView` with characteristic value rendering by accessing generated service wrappers from each `Accessory`.

## Next Steps
- Add accessory detail view showing services + characteristics.
- Add snapshot export button using `AtlasSnapshotEncoder`.
