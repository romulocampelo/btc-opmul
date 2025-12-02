# Environment Setup and Build Instructions for Bitcoin Core  
(OP_MUL Implementation)

This document describes the complete procedure used to reproduce and build the Bitcoin Core environment required for validating the `OP_MUL` opcode.  
The workflow follows Bitcoin Core’s official development model to ensure reproducibility, determinism, and methodological consistency.

---

## 1. Reference Development Environment

All experiments and tests for this project were performed under the following configuration:

- **Operating System:** Windows 11  
- **Compiler Toolchain:** Microsoft Visual C++ 2022 (MSVC)  
- **Build System:** CMake (multi-generator)  
- **Bitcoin Core Branch:** `master` (clean checkout)  
- **Python Version:** 3.10+ (required for functional tests)  
- **Additional Tools:** Git, Ninja (optional), Visual Studio Build Tools  

Although Windows is used as the reference platform, the workflow applies to Linux and macOS with minor adjustments.

---

## 2. Cloning Bitcoin Core

Begin with a clean clone of the upstream repository:

```bash
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
```

It is strongly recommended to start from a fresh commit before applying the patch.

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

Expected modified entries include:

- `src/script/interpreter.cpp`  
- `src/script/script_error.h` and `script_error.cpp`  
- `src/script/script.cpp`  
- `src/test/script_tests.cpp`  
- new functional test scripts under `test/functional/`

---

## 4. Generating the Build Configuration

### 4.1 Visual Studio Generator (recommended on Windows)

```bash
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Release ..
```

This produces a Visual Studio `.sln` solution containing all build targets.

### 4.2 Ninja Generator (for faster command-line builds)

```bash
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
```

Ninja builds typically complete significantly faster than Visual Studio builds.

---

## 5. Building Bitcoin Core

### 5.1 Visual Studio Build

Open the generated `.sln` file and select the **Release** configuration.  
Build the following targets:

- `bitcoind`  
- `bitcoin-cli`  
- `bitcoin-tx`

### 5.2 Ninja Build

Run:

```bash
ninja
```

Compiled binaries are generally located under:

```
bitcoin/build/bin/Release/
```

---

## 6. Preparing the Functional Testing Environment

Bitcoin Core’s functional tests require the following Python dependencies:

- `pyzmq`  
- `requests`  
- `python-bitcoinrpc` (bundled with the test framework)

Install them using:

```bash
pip install -r test/functional/requirements.txt
```

The test framework will automatically detect environmental capabilities and skip wallet-dependent scenarios when the wallet module is unavailable.

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
All experiments, functional testing procedures, and validation steps described in this project assume this environment as their baseline.
