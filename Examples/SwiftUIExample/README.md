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

For iOS/macOS interactive previews, open the package in Xcode 16 and run the `HomeAtlasSwiftUIExample` target.

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
