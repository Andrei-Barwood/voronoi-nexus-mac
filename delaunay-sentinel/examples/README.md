# Examples

This folder contains advanced usage examples for **delaunay-sentinel**.

## Input Files (`inputs/`)

| File                        | Purpose                                   | Expected Behavior             |
|-----------------------------|-------------------------------------------|-------------------------------|
| `clean.json`                | Low-risk / benign signals                 | 0 alerts (success)            |
| `high-risk.json`            | Multiple critical + high malware indicators | Several critical/high alerts  |
| `mixed.json`                | Mix of severities (based on original)     | Multiple findings             |
| `low-confidence.json`       | Signals below default threshold           | Filtered out (clean)          |
| `realistic-malware.json`    | Realistic malware telemetry field names   | High number of alerts         |

## Scripts & Demos

- **`batch-process.sh`** — Process all input files in one go. Supports `--debug`, `--json-summary`. Great for CI or bulk malware sample analysis.
- **`library-usage/`** — Complete minimal Swift package demonstrating how to use `DelaunaySentinel` as a **library** from your own code (not just the CLI binary).

## How to Use

From the project root:

```bash
# Batch process everything
./examples/batch-process.sh

# Run the library demo
cd examples/library-usage
swift run LibraryDemo
```

See [../TUTORIAL.md](../TUTORIAL.md) for detailed explanations.
