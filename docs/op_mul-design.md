```markdown
# Design Rationale and Formal Specification of OP_MUL (0x95)

This document presents a formal and academically rigorous description of the design, semantics, and implementation criteria adopted for the opcode `OP_MUL`, integrated into Bitcoin Core's Script interpreter.

---

## 1. Motivation

Bitcoin Script includes a limited set of arithmetic opcodes for integer manipulation. However, it does not include a dedicated multiplication operator, despite the strong need in advanced covenant constructions, accumulators, and algebraic verification scripts.

The goal of this opcode is:

- to introduce safe and deterministic integer multiplication,
- while respecting the constraints of Bitcoin Script (minimalism, determinism, consensus-critical safety),
- and ensuring compatibility with the existing `CScriptNum` model.

---

## 2. Operational Semantics

`OP_MUL` consumes two elements from the stack:

`..., x1, x2 → ..., (x1 * x2`

Both operands:

- are interpreted as **signed 32-bit integers**,
- are extracted via `CScriptNum` with a **4-byte encoding limit** (ensuring compatibility with other arithmetic opcodes).

### **Formal Definition**

Let:

- `x1, x2 ∈ ℤ32` (signed 32-bit domain),
- multiplication occurs in ℤ64 (intermediate domain).

Define:

`p = x1 × x2`


Then:

- If `p ∈ [-2³¹, 2³¹ − 1]`, the result is pushed onto the stack.
- Otherwise, script evaluation terminates with the error `SCRIPT_ERR_MUL`.

---

## 3. Overflow Handling

Bitcoin Script requires deterministic behavior across all node implementations.

Accordingly:

1. `x1` and `x2` are promoted to `int64_t`.
2. The product `p = x1 * x2` is computed in 64-bit precision.
3. Overflow is detected via explicit boundary checks:
   - `p < INT32_MIN`  
   - `p > INT32_MAX`
4. If overflow occurs:
   - the interpreter raises `SCRIPT_ERR_MUL`,
   - evaluation is aborted,
   - no value is pushed.

This design avoids wrap-around, which would violate consensus determinism.

---

## 4. Integration Points in Bitcoin Core

The implementation modifies the following components:

- `src/script/interpreter.cpp`  
  Addition of the `case OP_MUL` block implementing operational semantics.

- `src/script/script_error.h`  
  Introduction of the error code `SCRIPT_ERR_MUL`.

- `src/script/script.cpp`  
  Human-readable string for the new error code.

- Unit tests (`src/test/script_tests.cpp`)  
  Validation of overflow and correct computation.

- Functional tests (`test/functional/*.py`)  
  Independent verification of script behavior within full node execution.

---

## 5. Design Principles and Constraints

The design adheres to the following principles:

- **Determinism** — identical behavior across all architectures.
- **Minimalism** — the opcode does not introduce new data types.
- **Safety** — all edge cases are explicitly defined.
- **Backward compatibility** — no existing scripts are affected.
- **Consensus soundness** — every error mode leads to unambiguous script failure.

---

## 6. ASCII Execution Diagram

```
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
[..., p] or Script Failure
```

---

## 7. Conclusion

`OP_MUL` provides a mathematically well-defined, deterministic, and safe extension to Bitcoin Script’s arithmetic subsystem.  
The opcode integrates cleanly into the interpreter, follows the conventions of existing numeric operations, and is accompanied by thorough unit and functional testing ensuring correctness.
