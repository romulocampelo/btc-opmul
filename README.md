# Implementation and Analysis of OP_MUL (0x95) in Bitcoin Core

This repository documents the design, implementation, testing, and analysis of a new Bitcoin Script opcode:

**OP_MUL = 0x95**  
**Operation:** Signed 32-bit integer multiplication with explicit overflow validation.

The goal of this work is to extend the Bitcoin Core Script interpreter with a mathematically sound, deterministic, and consensus-safe multiplication primitive, implemented according to the canonical `CScriptNum` numeric rules.

This repository contains **only documentation, patch files, auxiliary scripts, and explanatory material**.  
The **Bitcoin Core source code is not included**, following licensing requirements and academic best practices.

---

## 1. Research Objective

This work has two complementary objectives:

### 1.1 Technical Contribution

Introduce a deterministic and safely constrained multiplication opcode into Bitcoin Script, respecting:

- strict overflow semantics,  
- the 32-bit signed integer domain (`[-2^31, 2^31 − 1]`),  
- the canonical 4-byte `CScriptNum` numeric representation.

The implementation follows the structure and conventions of the Bitcoin Core Script interpreter.

### 1.2 Pedagogical Contribution

Provide a clear and reproducible case study showing:

- how new opcodes can be integrated into Bitcoin Core,  
- how to design and validate arithmetic semantics for consensus-critical software,  
- how to construct unit tests, script tests, and functional tests in a controlled environment.

---

## 2. Semantics of OP_MUL

`OP_MUL` pops the top two stack elements, interprets them as 32-bit signed integers, multiplies them in 64-bit space, validates the result against the allowed domain, and either pushes the result or fails the script.

### 2.1 Formal Definition

Let:

- `x1`, `x2` ∈ ℤ₃₂ (signed 32-bit domain),  
- multiplication performed in ℤ₆₄,  
- `p = x1 × x2`.

Then:

```text
If -2^31 ≤ p ≤ 2^31 − 1:
    push(p)
Else:
    fail with SCRIPT_ERR_MUL
```

This behavior mirrors the deterministic integer semantics already used by other arithmetic opcodes in Bitcoin Script.

---

## 3. Execution Flow of OP_MUL

```text
       ┌───────────────────────────────────────────────────┐
       │                 Bitcoin Script Stack              │
       └───────────────────────────────────────────────────┘

                          Initial State
                          --------------
                         [..., x1, x2]

                                  │
                                  ▼

                         OP_MUL Dispatch
                         ---------------
                       interpreter.cpp:

                       case OP_MUL:
                           pop x2
                           pop x1
                           parse as CScriptNum(4 bytes)
                           promote to int64
                           p = x1 * x2
                           if p outside int32:
                               return SCRIPT_ERR_MUL
                           push(p)
                           continue

                                  │
                 ┌────────────────┴────────────────┐
                 │                                 │
                 ▼                                 ▼
         If p fits 32 bits               If p overflows 32 bits
         ------------------              ------------------------
         Script continues               Script evaluation fails
         [..., p]                        SCRIPT_ERR_MUL
```

---

## 4. Repository Structure

This repository excludes the Bitcoin Core source tree and provides instead:

- **`patches/op_mul.diff`** — complete patch for Bitcoin Core `master`,  
- **`docs/`** — GitHub Pages documentation,  
- **`scripts/`** — utilities to run functional tests,  
- **`notes/`** — development log.

This separation preserves clarity, reproducibility, and licensing compliance.

---

## 5. Reproducing the Implementation

### 5.1 Clone Bitcoin Core

```bash
git clone https://github.com/bitcoin/bitcoin.git
```

### 5.2 Apply the patch

```bash
git apply patches/op_mul.diff
```

### 5.3 Build Bitcoin Core

Follow the official build documentation for your platform.  
For Windows (MSVC + CMake), see: `docs/bitcoin-core-setup.md`.

### 5.4 Run Tests

```bash
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```

---

## 6. Testing Summary

The implementation is validated through multiple layers:

### 6.1 C++ Unit Tests

- Boundary tests:  
  - `INT32_MAX × 1` accepted  
  - `INT32_MAX × 2` rejected  
- Mixed-sign multiplication  
- Zero multiplication  
- Conformance with `CScriptNum`

### 6.2 Python Functional Tests

- Correct arithmetic behavior  
- Deterministic overflow/underflow rejection  
- Proper failure propagation in Script and P2SH contexts  
- Graceful skip when wallet RPC is unavailable

All tests were executed on Windows (MSVC) and Linux, producing identical results.

---

## 7. Authors

- **Alberto Rômulo Nunes Campelo** (@romulocampelo)  
- **Antonio Barros Coelho**  
- **Carlos Eduardo da Silva Almeida**  
- **Giovanni Nogueira Catelli**  
- **Pedro Corbelino Melges Barrêto Sales**

---

## 8. License (MIT)

The project is distributed under the MIT License.

---

## 9. Academic Significance

This work demonstrates:

- how to design safe arithmetic semantics for consensus-critical systems,  
- how to reintroduce disabled opcodes responsibly in controlled environments,  
- how multi-layer testing pipelines can be constructed in Bitcoin Core,  
- how overflow-sensitive arithmetic can be validated rigorously in decentralized systems.

The methodology aligns with best practices in reproducible research and secure systems engineering.
