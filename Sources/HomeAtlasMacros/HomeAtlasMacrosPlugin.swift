// HomeAtlas Macro Plugin Entry Point
// Provides @Snapshotable macro for type-safe snapshot generation

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct HomeAtlasMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SnapshotableMacro.self
    ]
}
