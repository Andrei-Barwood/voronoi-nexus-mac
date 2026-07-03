# delaunay-sentinel Tutorials

This document contains two tutorials for the **delaunay-sentinel** Swift port of the Snocomm Malware Analyzer:

- **Basic Tutorial**: Get up and running in under 5 minutes and see real output.
- **Advanced Tutorial**: Full "pedal to the metal" production usage — optimized builds, universal binaries, global installation, library integration, and pipeline automation.

---

## Basic Tutorial: See It Working Quickly

### Prerequisites

- macOS 13 or later (Ventura+)
- Swift 5.9+ (comes with Xcode Command Line Tools)

Install Command Line Tools if you haven't:

```bash
xcode-select --install
```

### Step 1: Navigate to the project

```bash
cd /path/to/voronoi-nexus-mac/delaunay-sentinel
# or wherever you cloned the mac port
```

### Step 2: Build the project (debug is fine for now)

```bash
swift build
```

This will fetch `swift-argument-parser` and compile everything.

### Step 3: Run the built-in demo

```bash
./.build/debug/delaunay-sentinel analyze --sample
```

**Expected output** (approximate):

```
🚀 Iniciando misión: The Gunslinger
🛡️  Rol: malware-analyzer
────────────────────────────────────────────────────

[Informe de Misión]
──────────────────────────────
Estado: WARNING
Mensaje: Analysis completed: 4 alerts generated

Total checks: 8
Alerts generadas: 4

Hallazgos:
  1. beaconing_to_c2
     • Severidad : CRITICAL
     ...
```

You should see colored output and several findings (CRITICAL + HIGH).

### Step 4: Try machine-readable output

```bash
./.build/debug/delaunay-sentinel analyze --sample --json
```

This prints clean JSON you can pipe to other tools.

### Step 5: Use your own input data

We provide several ready-made examples in `examples/inputs/`:

```bash
# Safe data (should be clean)
./.build/debug/delaunay-sentinel analyze --input examples/inputs/clean.json

# High risk malware sample
./.build/debug/delaunay-sentinel analyze --input examples/inputs/high-risk.json

# Realistic telemetry
./.build/debug/delaunay-sentinel analyze --input examples/inputs/realistic-malware.json
```

See [examples/README.md](examples/README.md) for a full list of sample inputs.

### Step 6: Pipe JSON from stdin

```bash
cat my-sample.json | ./.build/debug/delaunay-sentinel analyze
```

or

```bash
./.build/debug/delaunay-sentinel analyze --stdin < my-sample.json
```

### What just happened?

The tool analyzes malware indicators and telemetry, raising findings when signals exceed the confidence threshold and match known risk patterns (packed, evasion, beaconing, callbacks, anti-vm, persistence, etc.).

---

## Advanced Tutorial: Full Pedal to the Metal

This section shows how to use `delaunay-sentinel` like a serious production malware analysis tool.

### 1. Build the Fastest Possible Binary

```bash
# Optimized release build
swift build -c release
```

The binary will be at:

```bash
.build/release/delaunay-sentinel
```

Use it directly:

```bash
./.build/release/delaunay-sentinel analyze --sample
```

### 2. Build a Universal Binary (arm64 + Intel)

This is the "full pedal" version that runs natively everywhere on macOS:

```bash
# Build for both architectures
swift build -c release --arch arm64 --arch x86_64
```

Then combine them:

```bash
lipo -create \
  .build/arm64-apple-macosx/release/delaunay-sentinel \
  .build/x86_64-apple-macosx/release/delaunay-sentinel \
  -output delaunay-sentinel-universal

chmod +x delaunay-sentinel-universal
```

Or use the included Makefile:

```bash
make universal
```

The resulting `delaunay-sentinel-universal` is a fat binary.

### 3. Install Globally (Recommended)

```bash
# Install to /usr/local/bin (most common on macOS)
sudo cp .build/release/delaunay-sentinel /usr/local/bin/delaunay-sentinel
sudo chmod +x /usr/local/bin/delaunay-sentinel

# Or using the universal version
sudo cp delaunay-sentinel-universal /usr/local/bin/delaunay-sentinel
```

Now you can run it from anywhere:

```bash
delaunay-sentinel analyze --sample
delaunay-sentinel --help
```

### 4. Use the Makefile (Convenience Targets)

The project includes a `Makefile`:

```bash
make                # builds release
make release        # explicit release build
make run-sample     # swift run + --sample
make run-json       # swift run + --json
make universal      # creates fat binary
make clean          # removes build artifacts
```

### 5. Tune the Engine Like a Pro

Use different thresholds depending on your use case:

```bash
# Very sensitive (catch everything)
delaunay-sentinel analyze --input sample.json \
  --severity-threshold medium \
  --confidence-threshold 0.55

# High confidence only (low noise)
delaunay-sentinel analyze --input sample.json \
  --severity-threshold high \
  --confidence-threshold 0.92

# Disable enrichment for minimal output
delaunay-sentinel analyze --input sample.json --no-enrichment --json
```

### 6. Batch Processing (Real-World Workloads)

We provide a ready-to-use batch script:

```bash
# Process every file in examples/inputs/
./examples/batch-process.sh

# Force debug build + get machine-readable summary
./examples/batch-process.sh --debug --json-summary
```

The script (`examples/batch-process.sh`) runs the analyzer against all JSON files, counts findings by severity, and exits with proper codes (useful in CI or malware sample repositories).

### 7. Integrate with Other Tools (jq, scripts, CI)

Process findings with `jq`:

```bash
delaunay-sentinel analyze --input sample.json --json | \
  jq '.data.findings[] | select(.severity == "critical")'
```

Count critical findings:

```bash
delaunay-sentinel analyze --input sample.json --json | \
  jq '.data.findings | map(select(.severity=="critical")) | length'
```

Simple bash automation example:

```bash
#!/bin/bash
INPUT=$1
RESULT=$(delaunay-sentinel analyze --input "$INPUT" --json)
ALERTS=$(echo "$RESULT" | jq '.data.alerts_count')

if [ "$ALERTS" -gt 0 ]; then
    echo "⚠️  $ALERTS alerts detected in $INPUT"
    echo "$RESULT" | jq '.data.findings'
    exit 1
else
    echo "✅ Clean"
    exit 0
fi
```

### 8. Use as a Swift Library (Not Just CLI)

The most powerful way to use this module is as a **library**.

A complete, runnable example lives here:

```bash
cd examples/library-usage
swift run LibraryDemo
```

It shows:

- Creating `DelaunaySentinel` with default and custom `ModuleConfig`
- Calling both `analyze(...)` and the lower-level `analyzeMalware(...)`
- Getting structured `DetectionReport` and `DetectionFinding` objects directly

See `examples/library-usage/Package.swift` and `Sources/LibraryDemo/main.swift` for the actual code.

This pattern lets you embed the malware analysis engine inside larger Swift applications, sandbox tools, or automated analysis pipelines without spawning a separate process.

Example dependency (from a different package):

```swift
dependencies: [
    .package(path: "../delaunay-sentinel")
],
targets: [
    .executableTarget(
        name: "MyMalwareAnalyzer",
        dependencies: [
            .product(name: "DelaunaySentinel", package: "delaunay-sentinel")
        ]
    )
]
```

### 9. Prepare for Distribution

**Strip the binary** (smaller size):

```bash
strip -x .build/release/delaunay-sentinel
```

**Universal + stripped**:

```bash
make universal
strip -x delaunay-sentinel-universal
```

For public distribution you would also:

- Code sign the binary (`codesign --sign "Developer ID" ...`)
- Notarize it (for macOS Gatekeeper)

### 10. Generate Realistic Test Data

You can quickly create test cases for malware analysis:

```bash
cat > high-risk-sample.json << 'EOF'
{
  "packed_upx": true,
  "evasion_process_hollowing": true,
  "beaconing_activity": true,
  "anti_analysis_vm": true,
  "high_entropy_code": 0.91
}
EOF

delaunay-sentinel analyze --input high-risk-sample.json
```

### 11. Performance Notes

- Release builds are dramatically faster and smaller than debug.
- The analysis is extremely fast (microseconds) — suitable for high-volume malware sample processing.
- JSON I/O is the slowest part when processing thousands of files.

---

## Quick Reference

| Goal                              | Command |
|-----------------------------------|---------|
| Quick demo                        | `swift build && ./.build/debug/delaunay-sentinel analyze --sample` |
| Fast production binary            | `swift build -c release` |
| Universal binary                  | `make universal` or `swift build -c release --arch arm64 --arch x86_64` |
| Install globally                  | `sudo cp .build/release/delaunay-sentinel /usr/local/bin/delaunay-sentinel` |
| Run all examples                  | `./examples/batch-process.sh` |
| Library usage demo                | `cd examples/library-usage && swift run LibraryDemo` |
| JSON pipeline                     | `delaunay-sentinel analyze --json \| jq ...` |
| Use the engine inside your code   | Depend on product `DelaunaySentinel` |
| Clean everything                  | `make clean` or `rm -rf .build` |

---

## Next Steps

- Explore the original Python module behavior in `corporate/delaunay_sentinel/`
- Adapt the same tutorial pattern for the other modules
- Add unit tests under `Tests/`
- Build a small orchestrator that runs multiple `*-sentinel` / `*-replica` binaries

---

**This tutorial follows the spirit of the original Snocomm module while taking full advantage of native Swift on macOS.**
