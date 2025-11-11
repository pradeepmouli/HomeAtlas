# Data Model: SwiftPM Deployment, Encodable, Naming

## Entities

### Wrapper Class
- **Description**: Swift type that wraps HomeKit objects (e.g., accessories, services, characteristics)
- **Fields**: Varies by wrapper; typically includes identifiers, names, types, and value fields
- **Relationships**: May reference other wrappers (e.g., a Service wrapper references Characteristic wrappers)
- **Validation**: Must not leak `Any`; must be type-safe; must document non-encodable fields

### Package Metadata
- **Description**: Information required for SwiftPM deployment
- **Fields**: name, version, description, authors, platforms, products, targets, dependencies
- **Validation**: Must be complete and valid for SwiftPM/Swift Package Index
