# Troubleshooting HomeAtlas Diagnostics

HomeAtlas surfaces actionable error metadata to help you correlate runtime failures with Apple HomeKit guidance from Developer Apple Context7 (`developer_apple`, HomeKit > Troubleshooting HomeKit Accessories). This guide explains how to interpret `HomeKitError` payloads and the diagnostic events emitted by `DiagnosticsLogger`.

## Understanding `HomeKitError`

Every fallible HomeKit call throws a `HomeKitError` enriched with accessory, service, and characteristic context gathered from the underlying `HMError`. Two high-signal cases:

- `.characteristicTransport(operation:context:underlying:)` — network or transport issues raised by HomeKit APIs. Inspect `context.characteristicType` and `error.diagnosticsMetadata["underlying"]` to align with Developer Apple transport troubleshooting guidance (`developer_apple`, HomeKit > Accessory Communication).
- `.characteristicTypeMismatch(expected:actual:context:)` — metadata drift between the accessory and the catalog. Use `context.serviceType` and `context.accessoryName` when filing feedback or prompting a firmware update.

Example handler:

```swift
catch let error as HomeKitError {
	switch error {
	case .characteristicTransport(_, let context, _):
		// Map to Developer Apple transport troubleshooting.
		print("Transport issue for", context.characteristicType, error.diagnosticsMetadata)
	default:
		break
	}
}
```

## Latency Threshold Notifications

`DiagnosticsLogger.shared` automatically records a warning-level event whenever an operation exceeds the configurable latency budget (default 500 ms). Pair the emitted `duration` with Developer Apple performance guidance (`developer_apple`, HomeKit > Optimizing Accessory Performance) to decide whether to throttle polling or surface a user-facing hint.

```swift
let token = DiagnosticsLogger.shared.addObserver { event in
	guard event.operation == .characteristicRead else { return }
	if event.duration > 0.5 {
		print("Slow read", event.metadata)
	}
}
```

Remove observers with `DiagnosticsLogger.shared.removeObserver(_:)` when no longer needed (e.g., in `deinit`).

## Integrating with External Telemetry

- Forward diagnostics to your logging stack by translating `DiagnosticsEvent.metadata` into structured attributes aligned with Developer Apple references.
- Tag events with the accessory identifier (`metadata["accessory.id"]`) so you can correlate user reports with Home app observations.
- Capture raw `underlying` errors for attachment to bug reports or internal dashboards.

## Reference Materials

- Developer Apple Context7 (`developer_apple`, HomeKit > Troubleshooting HomeKit Accessories)
- Developer Apple Context7 (`developer_apple`, HomeKit > Accessory Communication)
- Developer Apple Context7 (`developer_apple`, HomeKit > Optimizing Accessory Performance)
