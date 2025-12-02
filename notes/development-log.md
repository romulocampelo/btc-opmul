# Development Log for OP_MUL

This document provides a chronological engineering record of the design, implementation, and validation of the `OP_MUL` opcode for Bitcoin Core.  
It summarizes technical decisions, intermediate steps, and relevant milestones achieved throughout the project.

---

## 1. Environment and Baseline Configuration

- **Operating System:** Windows 11  
- **Compiler Toolchain:** MSVC 2022 + CMake  
- **Bitcoin Core Source:** Clean checkout from `master`  
- **Binary Output Directory:**  
  `C:\Dev\btc-opmul\bitcoin\build\bin\Release`

All tests and experiments were performed in this controlled environment to ensure reproducibility across the entire development process.

---

## 2. Major Development Milestones

### 2.1 Interpreter Integration

- Implemented `OP_MUL = 0x95` within `src/script/interpreter.cpp`.  
- Performed multiplication using a **64-bit intermediate domain** with explicit overflow detection.  
- Enforced canonical numeric decoding using `CScriptNum(4 bytes)` for both operands.  
- Added a deterministic failure path for invalid conditions via `SCRIPT_ERR_MUL`.

### 2.2 Error Handling and Messaging

- Introduced the new consensus error code in:  
  - `src/script/script_error.h`
- Added the corresponding human-readable message in:  
  - `src/script/script.cpp`

### 2.3 Script Test Vectors

- Updated `src/test/data/script_tests.json` to remove obsolete references to the historical disabled `MUL` opcode.  
- Added new Script test vectors for:
  - correct arithmetic,
  - negative multiplication,
  - zero multiplication,
  - deterministic overflow rejection.

### 2.4 Unit Tests (C++)

- Implemented dedicated unit tests in `src/test/script_tests.cpp`.  
- Verified:
  - acceptance of all valid 32-bit products,  
  - deterministic failure on signed overflow or underflow,  
  - correct stack consumption and push behavior.

### 2.5 Functional Tests (Python)

Implemented two functional test modules:

- **`test/functional/script_op_mul.py`**  
  Validates interpreter-level and Script-level semantics.

- **`test/functional/op_mul_numeric_overflow.py`**  
  Constructs P2SH transactions specifically designed to trigger overflow and ensures proper consensus rejection.

Validated:

- arithmetic correctness under regtest,  
- strict failure propagation under overflow (`SCRIPT_ERR_MUL`),  
- deterministic behavior across multiple runs,  
- automatic skipping of wallet-dependent functionality.

---

## 3. Verification and End-to-End Behavior

Using the combined test suite:

- Valid multiplications within the signed 32-bit domain consistently produced the correct stack output.  
- Overflow scenarios reliably triggered `SCRIPT_ERR_MUL`.  
- C++ unit tests and Python functional tests produced deterministic, reproducible results.  
- No regressions were observed with existing opcodes or Script interpreter logic.  
- The implementation adhered fully to Bitcoin Core’s consensus-critical constraints.

---

## 4. Final Notes

This development log summarizes the main engineering steps without reproducing full code listings.  
Detailed documentation—including design rationale, formal specification, testing methodology, and environment setup—is available in the `/docs` directory.

The implementation is complete, validated, and aligned with Bitcoin Core’s conventions for deterministic, consensus-safe arithmetic operations.
