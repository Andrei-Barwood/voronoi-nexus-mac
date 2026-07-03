# Examples

This folder contains advanced usage examples for **affine-replica**.

## Input Files (`inputs/`)

| File                        | Purpose                              | Expected Behavior          |
|-----------------------------|--------------------------------------|----------------------------|
| `clean.json`                | Safe / low-risk signals              | 0 alerts (success)         |
| `high-risk.json`            | Multiple critical + high indicators  | Several critical alerts    |
| `mixed.json`                | Mix of severities + noise            | Multiple findings          |
| `low-confidence.json`       | Signals below default threshold      | Filtered out (clean)       |
| `realistic-telemetry.json`  | More realistic field names           | High number of alerts      |

## Scripts & Demos

- **`batch-process.sh`** — Process all input files in one go. Supports `--debug`, `--json-summary`. Great for CI or bulk analysis.
- **`library-usage/`** — Complete minimal Swift package demonstrating how to use `AffineReplica` as a **library** from your own code (not just the CLI binary).

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
