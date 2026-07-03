# elliptic-proof Tutorials

This document contains two tutorials for the **elliptic-proof** Swift port of the Snocomm Crypto Analyzer:

- **Basic Tutorial**: Get up and running in under 5 minutes.
- **Advanced Tutorial**: Full "pedal to the metal" production usage.

---

## Basic Tutorial: See It Working Quickly

### Prerequisites

- macOS 13+
- Swift 5.9+ (`xcode-select --install`)

### Step 1: Navigate

```bash
cd elliptic-proof
```

### Step 2: Build

```bash
swift build
```

### Step 3: Run the demo

```bash
./.build/debug/elliptic-proof analyze --sample
```

You will see:

```
🚀 Iniciando misión: Good Intentions
🛡️  Rol: crypto-analyzer
...
Estado: WARNING
...
```

### Step 4: Machine readable

```bash
./.build/debug/elliptic-proof analyze --sample --json
```

### Step 5: Your own data

Use files from `examples/inputs/`:

```bash
./.build/debug/elliptic-proof analyze --input examples/inputs/high-risk.json
```

See `examples/README.md` for details.

### Step 6: Stdin

```bash
cat my-crypto.json | ./ .build/debug/elliptic-proof analyze
```

---

## Advanced Tutorial: Full Pedal to the Metal

### 1. Fast Release Build

```bash
swift build -c release
```

### 2. Universal Binary

```bash
swift build -c release --arch arm64 --arch x86_64
# or
make universal
```

### 3. Install Globally

```bash
sudo cp .build/release/elliptic-proof /usr/local/bin/
```

### 4. Makefile

```bash
make release
make run-sample
make universal
```

### 5. Batch Processing

```bash
./examples/batch-process.sh
./examples/batch-process.sh --debug --json-summary
```

### 6. Use as Library

```bash
cd examples/library-usage
swift run LibraryDemo
```

Full example in `examples/library-usage/`.

### 7. jq Pipelines & CI

```bash
elliptic-proof analyze --input data.json --json | jq '.data.findings[] | select(.severity=="critical")'
```

### 8. Performance & Distribution

- Use release builds
- `strip -x` the binary
- Code sign + notarize for distribution

---

## Quick Reference

| Goal                    | Command |
|-------------------------|---------|
| Quick demo              | `swift build && ./.build/debug/elliptic-proof analyze --sample` |
| Release                 | `swift build -c release` |
| Universal               | `make universal` |
| Global install          | `sudo cp .build/release/elliptic-proof /usr/local/bin/` |
| Batch                   | `./examples/batch-process.sh` |
| Library demo            | `cd examples/library-usage && swift run LibraryDemo` |
| JSON + jq               | `elliptic-proof analyze --json \| jq ...` |

---

**This tutorial follows the same pattern used across the voronoi-nexus-mac ports.**
