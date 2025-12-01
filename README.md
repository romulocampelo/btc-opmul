# Implementation and Analysis of OP_MUL (0x95) in Bitcoin Core

This repository presents the design, implementation, testing, and analysis of a new Bitcoin Script opcode:

**OP_MUL = 0x95**  
**Function:** Signed 32-bit integer multiplication with strict overflow detection.

The goal of this work is to extend the Bitcoin Core Script interpreter with a mathematically sound, explicitly validated multiplication primitive, while ensuring compliance with the existing `CScriptNum` numerical semantics.

This repository contains **only documentation, the patch file, auxiliary scripts, and explanatory material**.  
The **Bitcoin Core source code is not included**, respecting licensing boundaries and good academic practice.

---

## 1. Research Objective

The objective of this work is twofold:

1. **Technical Contribution**  
   Introduce a safe, deterministic, and fully tested multiplication opcode into Bitcoin Script, following all consistency rules enforced by Bitcoin Core, including:
   - deterministic overflow handling;
   - adherence to 32-bit signed integer domain;
   - byte-limited numerical encoding (`CScriptNum(4 bytes)`).

2. **Pedagogical Contribution**  
   Provide a clean, well-documented case study demonstrating:
   - how new opcodes can be integrated into Bitcoin Core,
   - how to construct unit and functional tests,
   - how to design safe arithmetic semantics for consensus-critical systems.

---

## 2. Overview of OP_MUL Semantics

`OP_MUL` consumes the top two stack elements, interprets them as 32-bit signed integers, multiplies them in 64-bit space, checks for overflow, and either pushes the result or signals failure.

### **Formal Definition**

Let:

- `x1`, `x2` ∈ ℤ32 (signed 32-bit integer domain)  
- Intermediate multiplication occurs in ℤ64  
- Define:  
p = x1 × x2
Then:

- If `p ∈ [-2³¹, 2³¹ - 1]` → Push(p)
- Else → Script fails with `SCRIPT_ERR_MUL`

---

## 3. OP_MUL Execution Flow (ASCII Diagram)

       ┌───────────────────────────────────────────────────┐
       │                 Bitcoin Script Stack               │
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

This diagram models the precise operational semantics and error-propagation path in consensus-critical execution.

---

## 4. Repository Structure

This repository intentionally excludes Bitcoin Core’s source code.  
Instead, it contains:

- `patches/op_mul.diff`  
  Patch file ready to apply on top of Bitcoin Core `master`.

- `docs/`  
  Full documentation site (GitHub Pages), including:
  - formal design rationale,
  - setup and build instructions,
  - testing strategy,
  - theoretical notes.

- `scripts/`  
  PowerShell and Bash scripts for running functional tests.

- `notes/`  
  Development log summarizing progressive refinements.

This ensures academic clarity and avoids mixing original source with explanatory material.

---

## 5. Reproducing the Implementation

### **Step 1 — Clone Bitcoin Core**

````markdown
```bash
git clone https://github.com/bitcoin/bitcoin.git
```

### **Step 2 — Apply the patch**

````markdown
```bash
git apply patches/op_mul.diff
```

### **Step 3 — Build Bitcoin Core**

Follow the official instructions for your platform.  
For Windows (MSVC + CMake), see:  
`docs/bitcoin-core-setup.md`

### **Step 4 — Run Tests**

Unit Tests (C++) and Functional Tests (Python):

```bash
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```

## 6. Testing Summary

The implementation is validated via:

### **C++ Unit Tests**
- `INT32_MAX * 1` accepted
- `INT32_MAX * 2` rejected (`SCRIPT_ERR_MUL`)
- Negative multiplication cases
- Zero-multiplication cases

### **Python Functional Tests**
- Verification of correct arithmetic behavior
- Verification of overflow/underflow rejection
- P2SH transaction rejection on overflow
- Automatic skip if no wallet RPC is available

Tests are reproducible and deterministic.

---

## 7. Authors

- **Alberto Rômulo Nunes Campelo** (@romulocampelo)
- **Antonio Barros Coelho** (@toninhobc)
- **Carlos Eduardo da Silva Almeida** (@CarlosEduardoSilvaAlmeida)
- **Giovanni Nogueira Catelli** (@Gigogas)
- **Pedro Corbelino Melges Barrêto Sales** (@PedroCorbs)

---

## 8. License (MIT)

MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


---

## 9. Academic Relevance

This project serves as a pedagogical demonstration for:

- safe extension of Bitcoin Script opcodes,
- the interplay between numeric semantics and consensus rules,
- design patterns within Bitcoin Core’s interpreter,
- development of deterministic functional tests,
- systematic validation of overflow-sensitive arithmetic in decentralized systems.

The methodology aligns with academic best practices in reproducible research and secure systems engineering.

