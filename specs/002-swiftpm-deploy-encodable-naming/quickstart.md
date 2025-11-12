# Quickstart: SwiftPM Deployment, Encodable, Naming

## Adding the Package via SwiftPM

1. Open your Xcode project.
2. Go to File > Add Packages...
3. Enter the package repository URL (to be finalized after naming review).
4. Select the version and add the package to your project.
5. Import the module in your Swift files:
   ```swift
   import HomeAtlas
   ```

## Using Encodable Wrappers

- Most wrapper classes conform to `Encodable`.
- To encode a wrapper:
   ```swift
   let encoder = JSONEncoder()
   let data = try encoder.encode(myWrapper)
   ```
- If a property cannot be encoded, it will be excluded or documented in the API docs.

## Naming Considerations

- The package name will be reviewed for uniqueness and clarity before public release.
- Check the Swift Package Index for conflicts before publishing.
