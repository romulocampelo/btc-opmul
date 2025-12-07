# Design Rationale and Formal Specification of OP_MUL (0x95)

This document provides a formal, academically rigorous description of the design decisions, semantics, and implementation criteria adopted for the opcode `OP_MUL`, integrated into Bitcoin Core's Script interpreter.

---

## 1. Motivation

Bitcoin Script includes a minimal arithmetic subsystem, offering only basic integer operations. Despite Script’s constrained nature, several advanced constructions—such as accumulator updates, covenant-like systems, polynomial evaluations, and algebraic verification templates—benefit from a safe and deterministic multiplication operator.

Multiplication existed in early Bitcoin releases but was disabled due to concerns about nondeterministic overflow behavior across architectures. This work reintroduces multiplication with **explicit, consensus-safe integer semantics**, aligned with the modern `CScriptNum` model.

The objectives are:

- to define a multiplication operator that is **safe**, **deterministic**, and **architecturally stable**;  
- to remain faithful to Script's design goals of minimalism, predictability, and consensus soundness;  
- to ensure interoperability with the integer domain enforced by `CScriptNum`.

---
## 2. Operational Semantics

`OP_MUL` operates on the top two elements of the stack:

```
..., x1, x2   →   ..., (x1 × x2)
```

Both operands are:

- interpreted as **signed 32-bit integers**,  
- decoded using `CScriptNum` with a **4-byte canonical encoding limit**.

### Formal Definition

Let:

- `x1, x2 ∈ ℤ₃₂` (signed 32-bit domain),  
- multiplication performed in `ℤ₆₄`.

Define:

```
p = x1 × x2
```

Then:

- If `p ∈ [-2³¹, 2³¹ − 1]`, the interpreter pushes `p` onto the stack.  
- Otherwise, execution terminates with `SCRIPT_ERR_MUL`.

This specification preserves compatibility with existing arithmetic opcodes while ensuring deterministic overflow handling.

---

## 3. Overflow Handling

Overflow must be handled **explicitly** to maintain consensus determinism across all architectures.

The interpreter follows this sequence:

1. Decode `x1` and `x2` as `CScriptNum(4 bytes)`.  
2. Promote both values to `int64_t`.  
3. Compute:
   ```
   p = x1 * x2
   ```
4. Perform boundary checks:
   - `p < INT32_MIN`  
   - `p > INT32_MAX`  
5. If overflow is detected:
   - raise `SCRIPT_ERR_MUL`,  
   - abort script evaluation,  
   - do not push any value.

This prevents wrap-around, undefined behavior, and architecture-dependent results—historical sources of nondeterminism in early Script arithmetic.

---

## 4. Integration Points in Bitcoin Core

The implementation modifies the following components:

- **`src/script/interpreter.cpp`**  
  Implements `case OP_MUL`, defining the operational semantics.

- **`src/script/script_error.h`**  
  Defines the new consensus error code: `SCRIPT_ERR_MUL`.

- **`src/script/script.cpp`**  
  Registers the human-readable error string.

- **Unit tests (`src/test/script_tests.cpp`)**  
  Validate correctness, boundary conditions, and overflow rejection.

- **Script test vectors (`src/test/data/script_tests.json`)**  
  Provide canonical serialization coverage.

- **Functional tests (`test/functional/*.py`)**  
  Validate behavior end-to-end in a running node.

Each integration point follows established Bitcoin Core development patterns and preserves full backward compatibility.

---

## 5. Design Principles and Constraints

The design adheres to the following principles:

- **Determinism**  
  Identical behavior across all supported platforms.

- **Minimality**  
  No new data types or encoding rules are introduced.

- **Safety**  
  All arithmetic edge cases are explicitly handled.

- **Consensus Soundness**  
  Every failure path maps to a well-defined consensus error.

- **Backward Compatibility**  
  No existing scripts or opcodes are affected.

These principles align with Script’s philosophy as a constrained and predictable execution environment.

---

## 6. ASCII Execution Diagram

```text
Input Stack:
[..., x1, x2]

Process:
  pop x2
  pop x1
  parse via CScriptNum(4 bytes)
  promote to int64
  p = x1 * x2
  if p outside INT32 range:
        fail with SCRIPT_ERR_MUL
  else:
        push(p)

Output Stack:
[..., p]        or        Script Failure
```

---

## 7. Conclusion

`OP_MUL` provides a mathematically precise, deterministic, and consensus-safe multiplication operator for Bitcoin Script.  
The opcode integrates cleanly into the interpreter, mirrors the conventions of existing arithmetic instructions, and is supported by comprehensive unit and functional tests.

This design forms a robust foundation for educational exploration, applied research, and controlled experimentation with Script-language extensions.
