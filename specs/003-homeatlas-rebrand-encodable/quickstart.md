# Quickstart: Exporting a Home snapshot (HomeAtlas)

This guide shows how a developer will export a Home snapshot to JSON using the HomeAtlas API. Signatures may evolve slightly during implementation.

## Snapshot export

```swift
import HomeAtlas

@MainActor
func exportSnapshot() async throws {
    // Planned API shape
    let options = SnapshotOptions(anonymize: false)
    let data = try await HomeAtlas.encodeSnapshot(options: options)

    // Save to file
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("home-snapshot.json")
    try data.write(to: url)
}
```

- Deterministic ordering for Rooms, Accessories, Services, Characteristics.
- Unreadable values are encoded as `null` with a sibling `reason` string.
- Use `anonymize: true` to mask names/identifiers before sharing.

## CLI (planned)

```bash
# Planned command-line support will surface through a dedicated snapshot subcommand:
homeatlas export --output home-snapshot.json --anonymize=false
```

