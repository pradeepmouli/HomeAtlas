import Foundation

/// Parses TBD (Text-Based Definition) files to extract exported symbols
struct TBDParser {
    let frameworkPath: String

    func parseSymbolsSync() throws -> Set<String> {
        let tbdPath = "\(frameworkPath).tbd"

        print("   Parsing TBD symbols from: \(tbdPath)")

        guard FileManager.default.fileExists(atPath: tbdPath) else {
            print("   ⚠️  TBD file not found, skipping symbol validation")
            return Set()
        }

        let content = try String(contentsOfFile: tbdPath, encoding: .utf8)
        let symbols = parseExportedSymbols(from: content)
        print("   Found \(symbols.count) exported symbols")
        return symbols
    }

    func parseSymbols() async throws -> Set<String> {
        try parseSymbolsSync()
    }

    private func parseExportedSymbols(from content: String) -> Set<String> {
        var symbols = Set<String>()

        // TBD files use YAML format
        // Look for 'exports:' section followed by symbol lists
        let lines = content.split(separator: "\n")
        var inExportsSection = false
        var inSymbolsSection = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Check if we're entering the exports section
            if trimmed.hasPrefix("exports:") {
                inExportsSection = true
                continue
            }

            // Check if we're in the symbols subsection
            if inExportsSection && trimmed.hasPrefix("symbols:") {
                inSymbolsSection = true
                continue
            }

            // Parse symbol entries
            if inSymbolsSection {
                // Symbols are listed with leading dash and optional brackets
                // Example: - _HMServiceTypeLightbulb
                // Example: - [ 'armv7', 'arm64' ]: _HMServiceTypeLightbulb

                if trimmed.hasPrefix("-") {
                    // Extract symbol name after the dash
                    let symbolLine = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)

                    // Handle architecture-specific symbols: [ 'arch', 'arch' ]: _Symbol
                    if symbolLine.contains("]:") {
                        if let colonIndex = symbolLine.firstIndex(of: "]") {
                            let afterColon = symbolLine[symbolLine.index(after: colonIndex)...]
                                .trimmingCharacters(in: CharacterSet(charactersIn: ": \t"))
                            symbols.insert(String(afterColon))
                        }
                    } else {
                        // Simple symbol: - _Symbol
                        symbols.insert(symbolLine)
                    }
                } else if !trimmed.hasPrefix("#") && !trimmed.isEmpty && !trimmed.hasSuffix(":") {
                    // End of symbols section
                    inSymbolsSection = false
                }
            }

            // Reset when we hit a new top-level section
            if !trimmed.hasPrefix("-") && !trimmed.hasPrefix("#") && trimmed.hasSuffix(":") && !trimmed.hasPrefix(" ") {
                if trimmed != "exports:" && trimmed != "symbols:" {
                    inExportsSection = false
                    inSymbolsSection = false
                }
            }
        }

        return symbols
    }
}
