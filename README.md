# Voronoi Nexus - macOS Native Ports

Native macOS (Swift) command-line ports of the cybersecurity analysis modules from the [Snocomm Security Suite](https://github.com/Andrei-Barwood/voronoi-nexus).

This project converts the original Python modules into standalone, high-performance, universal binaries (Apple Silicon + Intel) that can be distributed independently.

## ✨ Completed Modules

| Module              | Binary Name          | Domain              | Mission              | Role                |
|---------------------|----------------------|---------------------|----------------------|---------------------|
| [affine-replica](./affine-replica) | `affine-replica`     | Emulation Engine    | American Distillation | emulation-engine    |
| [delaunay-sentinel](./delaunay-sentinel) | `delaunay-sentinel` | Malware Analyzer    | The Gunslinger       | malware-analyzer    |
| [elliptic-proof](./elliptic-proof) | `elliptic-proof`     | Crypto Analyzer     | Good Intentions      | crypto-analyzer     |

Each module includes:
- Full faithful port of the analysis logic
- Clean CLI powered by Swift ArgumentParser
- Support for `--sample`, `--input`, `--stdin`, configuration flags and `--json`
- Beautiful colored human-readable output + emojis
- `TUTORIAL.md` with basic + advanced "full pedal to the metal" guides
- `examples/` folder with ready-to-use inputs, batch processing script, and library usage demo

## 📦 Structure

Each port is a self-contained Swift Package:

```
<module>/
├── Package.swift
├── Sources/
│   ├── <ModuleName>/
│   │   ├── Models.swift
│   │   └── <ModuleName>.swift
│   └── <ModuleName>CLI/
│       └── main.swift
├── Makefile
├── README.md
├── TUTORIAL.md
├── sample-input.json
└── examples/
    ├── inputs/
    ├── batch-process.sh
    └── library-usage/
```

## 🚀 Usage Example

```bash
cd affine-replica
swift build -c release
./.build/release/affine-replica analyze --sample
```

## 🛠️ Building

```bash
# Inside any module directory
swift build -c release

# Universal binary (arm64 + x86_64)
swift build -c release --arch arm64 --arch x86_64
```

See the `Makefile` and `TUTORIAL.md` inside each module for more build options and installation instructions.

## 📖 Documentation

- Each module has its own **README.md** and **TUTORIAL.md**
- `module-port-prompts.txt` contains the conversion prompts for all ~77 modules

## 🎯 Goals

- 1:1 behavior with the original Python implementations
- Native performance and distribution
- Consistent CLI interface across all modules
- Easy to embed as libraries in larger Swift projects

## 🔗 Related

- Original repository: https://github.com/Andrei-Barwood/voronoi-nexus
- This macOS port: https://github.com/Andrei-Barwood/voronoi-nexus-mac

---

Contributions and feedback welcome!
