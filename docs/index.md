---
title: OP_MUL for Bitcoin Core
layout: default
---

<link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}" />

# OP_MUL for Bitcoin Core

This site documents the design, implementation, and evaluation of a new Bitcoin Script opcode:

```text
OP_MUL = 0x95
```

The opcode performs **signed 32-bit integer multiplication** within Bitcoin Script, using **explicit overflow detection** to ensure deterministic and consensus-safe behavior.

---

## Overview

This project introduces OP_MUL into the Bitcoin Core Script interpreter with:

- fully specified operational semantics,  
- strict overflow handling,  
- compatibility with `CScriptNum` (4-byte numeric limit),  
- complete unit and functional test coverage,  
- reproducibility across platforms.

The implementation follows Bitcoin Core’s development conventions and preserves all consensus invariants.

---

## Documentation

The sections below describe the project in detail:

- **[Design and Rationale for OP_MUL](op_mul-design.md)**  
  Formal semantics, design principles, and integration notes.
  
- **[Design Rationale for Arithmetic Patterns](integer_design_rationale.md)**  
  To understand the consensus risks of floating-point arithmetic and how to perform decimal calculations using `OP_MUL` with fixed-point logic.  

- **[Environment and Build Instructions](bitcoin-core-setup.md)**  
  How to reproduce the Bitcoin Core environment used in this work.

- **[Testing Strategy](testing.md)**  
  Unit tests, functional tests, and deterministic overflow validation.

- **[Security Considerations](security-considerations.md)**  
  Consensus safety, overflow failure modes, and system implications.

- **[Formal Specification](specification.md)**  
  Operational rules and exact arithmetic semantics.

Additional materials, including patch files and development logs, are available in the repository.

---

## Project Status

- **Implementation:** Complete  
- **Interpreter Integration:** Verified  
- **Unit Tests (C++):** All passing, including boundary and overflow cases  
- **Functional Tests (Python):**  
  - `script_op_mul.py`  
  - `op_mul_numeric_overflow.py`

---

## Overflow Behavior Summary

- If the product fits within the signed 32-bit domain, the result is pushed onto the stack.  
- If overflow occurs, script evaluation terminates with:

```text
SCRIPT_ERR_MUL
```

This ensures deterministic arithmetic consistent with Bitcoin’s consensus rules.

---

For detailed technical discussion and supporting material, see the documentation pages linked above.
