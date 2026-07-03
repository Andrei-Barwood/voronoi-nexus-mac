# affine-replica — Emulation Engine (Swift)

**Misión**: American Distillation  
**Rol**: emulation-engine  
**Estado**: Production (Swift port v3.0.0)

Native macOS command-line binary port of the original `affine_replica` module from the Snocomm / Voronoi Nexus suite.

> **New here?** → See the step-by-step **[TUTORIAL.md](TUTORIAL.md)** (Basic + Advanced "pedal to the metal" guides).

## Purpose

Emula la ejecución de artefactos para inferir intención y riesgos mediante análisis de señales de comportamiento.

## Build & Run

```bash
cd affine-replica

# Build debug
swift build

# Build release (recommended)
swift build -c release

# Run
./.build/release/affine-replica --help
./.build/release/affine-replica analyze --sample
```

The binary is located at:

```
.build/release/affine-replica
```

## Documentation

- [TUTORIAL.md](TUTORIAL.md) — Basic tutorial (5 minutes) + Advanced "full pedal to the metal" guide
- [examples/README.md](examples/README.md) — Ready-made input files + batch script + library usage demo
- [README.md](README.md) — This file (quick reference)

## Usage

```bash
# Built-in sample (produces several findings)
affine-replica analyze --sample

# JSON input file
affine-replica analyze --input my-execution.json

# Piped JSON
cat execution.json | affine-replica analyze

# Tune thresholds
affine-replica analyze --sample --severity-threshold high --confidence-threshold 0.85

# Machine readable output
affine-replica analyze --sample --json
```

### Exit Codes
- `0` — Clean (success)
- `1` — Warnings / alerts generated
- `2` — Error

## Configuration Flags

| Flag                        | Default   | Description                              |
|-----------------------------|-----------|------------------------------------------|
| `--severity-threshold`      | medium    | critical / high / medium / low           |
| `--confidence-threshold`    | 0.7       | 0.0 – 1.0                                |
| `--no-enrichment`           | false     | Disable enrichment in summary            |
| `--json`                    | false     | Emit full structured JSON                |
| `--sample`                  | —         | Use rich demo dataset                    |
| `--input <file>`            | —         | Load execution data from JSON file       |

## Input Format

The tool expects a JSON object where keys are indicator names and values are signals (numbers, booleans or strings).

Example:

```json
{
  "beaconing_activity": true,
  "persistence_mechanism": 0.95,
  "evasion_technique_detected": true,
  "packed_binary": "true"
}
```

## Mapping from Python Original

- `AffineReplica` → `AffineReplica` (class)
- `emulate_behavior(...)` → `emulateBehavior(...)`
- `analyze(execution_data=...)` → `analyze(executionData:)`
- `DetectionFinding` / `DetectionReport` / `AnalysisResult` ported to Swift structs
- All severity ranking, confidence normalization and risk token rules are implemented **identically** to the Python version.
- `recommendation` strings are preserved exactly.

## Differences / Improvements (Swift version)

- Proper CLI with ArgumentParser (subcommand `analyze`)
- Native colorized output + emojis matching the Snocomm style
- Built-in rich sample data designed to trigger multiple severity levels
- Universal binary support (see below)
- First-class `--json` with full findings array (nested)
- Clean separation: `AffineReplica` library + CLI target

## Building a Universal macOS Binary

```bash
cd affine-replica

# Build for both architectures
swift build -c release --arch arm64 --arch x86_64

# The resulting binary in .build/apple/Products/Release/ is usually a fat binary already.
# Or manually:

lipo -create \
  .build/arm64-apple-macosx/release/affine-replica \
  .build/x86_64-apple-macosx/release/affine-replica \
  -output affine-replica-universal

chmod +x affine-replica-universal
```

## Future

This package follows the same prompt template as the other 76 modules in the voronoi-nexus → mac port effort.

---

Ported following the official conversion prompt for `affine_replica`.
Original source: https://github.com/Andrei-Barwood/voronoi-nexus/tree/main/corporate/affine_replica
