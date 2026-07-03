# delaunay-sentinel — Malware Analyzer (Swift)

**Misión**: The Gunslinger  
**Rol**: malware-analyzer  
**Estado**: Production (Swift port v3.0.0)

Native macOS command-line binary port of the original `delaunay_sentinel` module from the Snocomm / Voronoi Nexus suite.

> **New here?** → See the step-by-step **[TUTORIAL.md](TUTORIAL.md)** (Basic + Advanced "pedal to the metal" guides).

## Purpose

Analiza muestras y telemetría para clasificar malware y su peligrosidad.

## Build & Run

```bash
cd delaunay-sentinel

# Build debug
swift build

# Build release (recommended)
swift build -c release

# Run
./.build/release/delaunay-sentinel --help
./.build/release/delaunay-sentinel analyze --sample
```

The binary is located at:

```
.build/release/delaunay-sentinel
```

## Documentation

- [TUTORIAL.md](TUTORIAL.md) — Basic tutorial (5 minutes) + Advanced "full pedal to the metal" guide
- [examples/README.md](examples/README.md) — Ready-made input files + batch script + library usage demo
- [README.md](README.md) — This file (quick reference)

## Usage

```bash
# Built-in sample (produces several findings)
delaunay-sentinel analyze --sample

# JSON input file
delaunay-sentinel analyze --input my-sample.json

# Piped JSON
cat sample.json | delaunay-sentinel analyze

# Tune thresholds
delaunay-sentinel analyze --sample --severity-threshold high --confidence-threshold 0.85

# Machine readable output
delaunay-sentinel analyze --sample --json
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
| `--input <file>`            | —         | Load sample data from JSON file          |

## Input Format

The tool expects a JSON object where keys are malware indicators/signals and values are numeric scores, booleans or strings.

Example:

```json
{
  "suspicious_imports": 9,
  "packed_binary": true,
  "network_callbacks": 5,
  "anti_vm_checks": true
}
```

## Mapping from Python Original

- `DelaunaySentinel` → `DelaunaySentinel` (class)
- `analyze_malware(sample_data)` → `analyzeMalware(sampleData:)`
- `analyze(sample_data=...)` → `analyze(sampleData:)`
- `DetectionFinding` / `DetectionReport` / `AnalysisResult` ported to Swift structs
- All severity ranking, confidence normalization and risk token rules are implemented **identically** to the Python version.
- `recommendation` strings are preserved exactly.

## Differences / Improvements (Swift version)

- Proper CLI with ArgumentParser
- Native colorized output + emojis
- Built-in rich sample data
- Universal binary support
- First-class `--json` with full findings
- Library + CLI separation for reuse

## Building a Universal macOS Binary

```bash
cd delaunay-sentinel

swift build -c release --arch arm64 --arch x86_64
```

See `TUTORIAL.md` in sibling modules or the Makefile for lipo examples.

---

Ported following the official conversion prompt for `delaunay_sentinel`.
Original source: https://github.com/Andrei-Barwood/voronoi-nexus/tree/main/corporate/delaunay_sentinel
