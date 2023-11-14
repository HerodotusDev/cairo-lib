![](/banner.png)

# `cairo-lib`: Comprehensive Library for Cairo 🐺
[![CI](https://github.com/HerodotusDev/cairo-lib/actions/workflows/ci.yml/badge.svg)](https://github.com/HerodotusDev/cairo-lib/actions/workflows/ci.yml)

Welcome to `cairo-lib` – a comprehensive library for the Cairo language. This library provides a suite of tools to supercharge your Cairo development experience. Inspired by [Alexandria](https://github.com/keep-starknet-strange/alexandria).

**⚠️ Disclaimer**: This library is in its early stages and has not been audited yet. It may contain bugs or vulnerabilities. Use at your own risk and ensure proper review and testing when integrating into your projects.

## Features

- [**Data Structures**](./src/data_structures/)
- [**Encoding**](./src/encoding/)
- [**Hashers**](./src/hashing/)
- [**Utilities**](./src/utils/)

## Getting Started

### Building
To compile the library:
```bash
scarb build
```

### Formatting:
To format your code:
```bash
scarb fmt
```

### Testing
Run the tests using:
```bash
scarb test
```

### Installation
Add to your `Scarb.toml` dependencies:
```toml
[dependencies]
cairo_lib = { git = "https://github.com/HerodotusDev/cairo-lib.git" }
```

### Usage
For example, to utilize a specific tool from the library:
```cairo
use cairo_lib::utils::types::words64::{Words64, Words64Trait};
```

## License
`cairo-lib` is licensed under the [GNU General Public License v3.0](./LICENSE).
