# elliptic-proof — Crypto Analyzer (Swift)

**Misión**: Good Intentions  
**Rol**: crypto-analyzer  
**Estado**: Production (Swift port v3.0.0)

Native macOS port of the `elliptic_proof` module.

> **New here?** → See **[TUTORIAL.md](TUTORIAL.md)**

## Build

```bash
cd elliptic-proof
swift build -c release
./.build/release/elliptic-proof analyze --sample
```

## Documentation

- [TUTORIAL.md](TUTORIAL.md) — Basic + Advanced "full pedal to the metal" guide
- [examples/README.md](examples/README.md) — Sample inputs, batch script & library demo

## Usage

```bash
elliptic-proof analyze --sample
elliptic-proof analyze --input crypto-data.json --json
```

Binary: `elliptic-proof`
