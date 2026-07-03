# Library Usage Example

This folder demonstrates how to consume the `DelaunaySentinel` **library** (not the CLI) from another Swift package.

## How to Run

From the `delaunay-sentinel` root:

```bash
cd examples/library-usage

# Build and run the demo
swift run LibraryDemo
```

It will:

- Import `DelaunaySentinel`
- Create the engine with default and custom config
- Call `analyze(...)` and `analyzeMalware(...)` directly
- Show structured `DetectionReport` and `DetectionFinding` objects

## Why This Matters

By depending on the library target, you can embed the exact same malware analysis logic inside:

- Other CLI tools
- macOS apps
- Background agents / daemons
- Test suites
- Larger security orchestration systems

You get the full power of the analyzer without spawning a subprocess.

## Dependency Reference

See `Package.swift` in this folder:

```swift
.package(path: "../../")   // points at the parent delaunay-sentinel package
```

Then:

```swift
dependencies: ["DelaunaySentinel"]
```

## Advanced Integration Ideas

- Feed data from malware sandboxes or endpoint telemetry
- Combine with other modules (once ported)
- Add custom enrichment logic on top of `DetectionFinding`
- Export findings to JSON, SIEM, or threat intel platforms
