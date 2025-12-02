# Environment Setup and Build Instructions for Bitcoin Core (OP_MUL Implementation)

This document describes the complete procedure used to reproduce, build, and test the Bitcoin Core environment required for validating the `OP_MUL` opcode implementation.  
The workflow follows Bitcoin Core’s official development model to ensure reproducibility, determinism, and methodological consistency.

---

## 1. Reference Development Environment

All experiments and tests for this project were performed using the configuration below:

- **Operating System:** Windows 11  
- **Compiler Toolchain:** Microsoft Visual C++ (MSVC 2022)  
- **Build System:** CMake (multi-generator)  
- **Bitcoin Core Branch:** `master` (clean checkout)  
- **Python Version:** 3.10+ (required for functional tests)  
- **Additional Tools:** Git, Ninja (optional), Visual Studio Build Tools  

Although these instructions use Windows as the reference platform, the same workflow applies to Linux and macOS with minor adjustments.

---

## 2. Cloning Bitcoin Core

Begin with a clean clone of the upstream repository:

```bash
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
```

It is strongly recommended to work from a fresh commit before applying the patch.

---

## 3. Applying the OP_MUL Patch

Apply the project’s patch file to the Bitcoin Core source tree:

```bash
git apply path/to/op_mul.diff
```

If the patch applies cleanly, no output is produced.

Verify the modified files:

```bash
git status
```

Expected entries include:

- `src/script/interpreter.cpp`  
- `src/script/script_error.h` and `script_error.cpp`  
- `src/script/script.cpp`  
- `src/test/script_tests.cpp`  
- additional functional test scripts added under `test/functional/`

---

## 4. Generating the Build Configuration

### 4.1 Visual Studio Generator (recommended on Windows)

```bash
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Release ..
```

This produces a Visual Studio `.sln` solution containing all build targets.

### 4.2 Ninja Generator (faster command-line builds)

```bash
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
```

Ninja builds tend to be significantly faster.

---

## 5. Building Bitcoin Core

### 5.1 Visual Studio Build

Open the generated `.sln` file and select the **Release** configuration.  
Build the following targets:

- `bitcoind`  
- `bitcoin-cli`  
- `bitcoin-tx`

### 5.2 Ninja Build

Simply run:

```bash
ninja
```

Compiled binaries are typically located at:

```
bitcoin/build/bin/Release/
```

---

## 6. Preparing the Functional Testing Environment

Bitcoin Core’s functional testing framework requires the following Python dependencies:

- `pyzmq`  
- `requests`  
- `python-bitcoinrpc` (bundled with the framework)

Install them using:

```bash
pip install -r test/functional/requirements.txt
```

Tests will automatically detect environmental capabilities and conditionally skip wallet-dependent scenarios if the wallet module is unavailable.

---

## 7. Running the Test Suite

### 7.1 C++ Unit Tests

```bash
src/test/test_bitcoin.exe
```

### 7.2 Functional Tests (Python)

Execute the OP_MUL-specific tests:

```bash
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```

These tests validate:

- arithmetic correctness,  
- stack behavior,  
- overflow rejection,  
- consensus error propagation (`SCRIPT_ERR_MUL`),  
- end-to-end Script evaluation within a regtest node.

---

## 8. Conclusion

Following the steps above yields a clean, deterministic build of Bitcoin Core containing the `OP_MUL` implementation.  
All experiments, functional testing procedures, and validation steps documented in this project assume this environment as their baseline.
