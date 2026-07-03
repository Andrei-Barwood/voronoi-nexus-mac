# affine-replica Tutorials

This document contains two tutorials for the **affine-replica** Swift port of the Snocomm Emulation Engine:

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
cd /path/to/voronoi-nexus-mac/affine-replica
# or wherever you cloned the mac port
```

### Step 2: Build the project (debug is fine for now)

```bash
swift build
```

This will fetch `swift-argument-parser` and compile everything.

### Step 3: Run the built-in demo

```bash
./.build/debug/affine-replica analyze --sample
```

**Expected output** (approximate):

```
🚀 Iniciando misión: American Distillation
🛡️  Rol: emulation-engine
────────────────────────────────────────────────────

[Informe de Misión]
──────────────────────────────
Estado: WARNING
Mensaje: Analysis completed: 6 alerts generated

Total checks: 10
Alerts generadas: 6

Hallazgos:
  1. beaconing_activity
     • Severidad : CRITICAL
     • Confianza : 1.00
     • Categoría : emulation-engine
     • Recomendación: Escalar al SOC y activar playbook de contención

  2. persistence_mechanism
     • Severidad : CRITICAL
     ...
```

You should see colored output and several findings (CRITICAL + HIGH).

### Step 4: Try machine-readable output

```bash
./.build/debug/affine-replica analyze --sample --json
```

This prints clean JSON you can pipe to other tools.

### Step 5: Use your own input data

We provide several ready-made examples in `examples/inputs/`:

```bash
# Safe data (should be clean)
./.build/debug/affine-replica analyze --input examples/inputs/clean.json

# High risk scenario
./.build/debug/affine-replica analyze --input examples/inputs/high-risk.json

# Realistic telemetry
./.build/debug/affine-replica analyze --input examples/inputs/realistic-telemetry.json
```

See [examples/README.md](examples/README.md) for a full list of sample inputs.

### Step 6: Pipe JSON from stdin

```bash
cat my-data.json | ./.build/debug/affine-replica analyze
```

or

```bash
./.build/debug/affine-replica analyze --stdin < my-data.json
```

### What just happened?

The tool emulates execution signals and raises findings when indicators exceed the confidence threshold and match risk patterns (beaconing, persistence, evasion, packed, etc.).

---

## Advanced Tutorial: Full Pedal to the Metal

This section shows how to use `affine-replica` like a serious production tool.

### 1. Build the Fastest Possible Binary

```bash
# Optimized release build
swift build -c release
```

The binary will be at:

```bash
.build/release/affine-replica
```

Use it directly:

```bash
./.build/release/affine-replica analyze --sample
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
  .build/arm64-apple-macosx/release/affine-replica \
  .build/x86_64-apple-macosx/release/affine-replica \
  -output affine-replica-universal

chmod +x affine-replica-universal
```

Or use the included Makefile:

```bash
make universal
```

The resulting `affine-replica-universal` is a fat binary.

### 3. Install Globally (Recommended)

```bash
# Install to /usr/local/bin (most common on macOS)
sudo cp .build/release/affine-replica /usr/local/bin/affine-replica
sudo chmod +x /usr/local/bin/affine-replica

# Or using the universal version
sudo cp affine-replica-universal /usr/local/bin/affine-replica
```

Now you can run it from anywhere:

```bash
affine-replica analyze --sample
affine-replica --help
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
affine-replica analyze --input data.json \
  --severity-threshold medium \
  --confidence-threshold 0.55

# High confidence only (low noise)
affine-replica analyze --input data.json \
  --severity-threshold high \
  --confidence-threshold 0.92

# Disable enrichment for minimal output
affine-replica analyze --input data.json --no-enrichment --json
```

### 6. Batch Processing (Real-World Workloads)

We provide a ready-to-use batch script:

```bash
# Process every file in examples/inputs/
./examples/batch-process.sh

# Force debug build + get machine-readable summary
./examples/batch-process.sh --debug --json-summary
```

The script (`examples/batch-process.sh`) runs the analyzer against all JSON files, counts findings by severity, and exits with proper codes (useful in CI).

### 7. Use as a Swift Library (Not Just CLI)

The most powerful way to use this module is as a **library**.

A complete, runnable example lives here:

```bash
cd examples/library-usage
swift run LibraryDemo
```

It shows:

- Creating `AffineReplica` with default and custom `ModuleConfig`
- Calling both `analyze(...)` and the lower-level `emulateBehavior(...)`
- Getting structured `DetectionReport` and `DetectionFinding` objects directly

See `examples/library-usage/Package.swift` and `Sources/LibraryDemo/main.swift` for the actual code.

This pattern lets you embed the emulation engine inside larger Swift applications, agents, or test harnesses without spawning a separate process.

Example dependency (from a different package):

```swift
dependencies: [
    .package(path: "../affine-replica")
],
targets: [
    .executableTarget(
        name: "MySecurityTool",
        dependencies: [
            .product(name: "AffineReplica", package: "affine-replica")
        ]
    )
]
```

### 8. Prepare for Distribution

**Strip the binary** (smaller size):

```bash
strip -x .build/release/affine-replica
```

**Universal + stripped**:

```bash
make universal
strip -x affine-replica-universal
```

For public distribution you would also:

- Code sign the binary (`codesign --sign "Developer ID" ...`)
- Notarize it (for macOS Gatekeeper)

### 9. Generate Realistic Test Data

You can quickly create test cases:

```bash
cat > high-risk.json << 'EOF'
{
  "beaconing_activity": true,
  "persistence_mechanism": 0.97,
  "evasion_technique_detected": true,
  "packed_binary": "true",
  "suspicious_entropy": 0.91,
  "callback_channel": true,
  "api_sequence_similarity": 0.88
}
EOF

affine-replica analyze --input high-risk.json
```

### 10. Performance Notes

- Release builds are dramatically faster and smaller than debug.
- The analysis is extremely fast (microseconds) — suitable for high-volume pipelines.
- JSON I/O is the slowest part when processing thousands of files.

---

## Quick Reference

| Goal                              | Command |
|-----------------------------------|---------|
| Quick demo                        | `swift build && ./.build/debug/affine-replica analyze --sample` |
| Fast production binary            | `swift build -c release` |
| Universal binary                  | `make universal` or `swift build -c release --arch arm64 --arch x86_64` |
| Install globally                  | `sudo cp .build/release/affine-replica /usr/local/bin/affine-replica` |
| Run all examples                  | `./examples/batch-process.sh` |
| Library usage demo                | `cd examples/library-usage && swift run LibraryDemo` |
| JSON pipeline                     | `affine-replica analyze --json \| jq ...` |
| Use the engine inside your code   | Depend on product `AffineReplica` |
| Clean everything                  | `make clean` or `rm -rf .build` |

---

## Next Steps

- Explore the original Python module behavior in `corporate/affine_replica/`
- Adapt the same tutorial pattern for the other 76 modules
- Add unit tests under `Tests/`
- Build a small orchestrator that runs multiple `*-replica` binaries

---

**This tutorial follows the spirit of the original Snocomm module while taking full advantage of native Swift on macOS.**