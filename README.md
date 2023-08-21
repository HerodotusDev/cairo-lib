# `cairo-lib`: Comprehensive Library for Cairo 🐺
[![CI](https://github.com/HerodotusDev/cairo-lib/actions/workflows/ci.yml/badge.svg)](https://github.com/HerodotusDev/cairo-lib/actions/workflows/ci.yml)

Welcome to `cairo-lib` – a comprehensive library for the Cairo language. This library provides a suite of tools to supercharge your Cairo development experience.

**⚠️ Disclaimer**: This library is in its early stages and has not been audited yet. It may contain bugs or vulnerabilities. Use at your own risk and ensure proper review and testing when integrating into your projects.

## Features:

- [**Data Structures**](https://github.com/HerodotusDev/cairo-lib/tree/main/src/data_structures):
  - Merkle Mountain Range
  - Ethereum Merkle Patricia Tree

- [**Encoding**](https://github.com/HerodotusDev/cairo-lib/tree/main/src/encoding):
  - RLP

- [**Hashers**](https://github.com/HerodotusDev/cairo-lib/tree/main/src/hashing):
  - Unified interface for hashing (includes Ethereum-compatible keccak256)

- [**Utilities**](https://github.com/HerodotusDev/cairo-lib/tree/main/src/utils):
  - Array tools
  - Bitwise
  - Math
  - Types (Byte & Bytes)

## Getting Started:

### Building:
To compile the library:
```bash
scarb build
```

### Testing:
Run the tests using:
```bash
scarb test
```

### Installation:
Add to your `Scarb.toml` dependencies:
```toml
[dependencies]
cairo_lib = { git = "https://github.com/HerodotusDev/cairo-lib.git" }
```

### Usage:
For example, to utilize a specific tool from the library:
```cairo
use cairo_lib::utils::types::bytes::Bytes;
```

## License
`cairo-lib` is licensed under the [GNU General Public License v3.0](./LICENSE).
