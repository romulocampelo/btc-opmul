# OP_MUL (0x95) — Formal Specification

This document provides a normative specification for the `OP_MUL` opcode implemented in Bitcoin Script.  
It follows the structure of a minimal Request for Comments (RFC) suitable for consensus-critical arithmetic semantics.

---

## 1. Opcode Identifier

```
Opcode:     OP_MUL
Hex Value:  0x95
Category:   Arithmetic
Status:     Active (project implementation)
```

---

## 2. Purpose

`OP_MUL` performs deterministic, signed 32-bit integer multiplication using a 64-bit intermediate result.  
It adheres to Script’s constrained numeric model and enforces strict overflow detection in accordance with the canonical `CScriptNum(4 bytes)` representation.

---

## 3. Inputs and Outputs

### 3.1 Stack Input

```
..., x1, x2  →  (top)
```

Where:

- `x1` and `x2` are integers encoded via `CScriptNum` with:
  - **maximum size:** 4 bytes  
  - **canonical encoding:** required  
  - **domain:** `[-2³¹, 2³¹ − 1]`

### 3.2 Stack Output

On success:

```
..., p
```

On failure:

- script terminates with `SCRIPT_ERR_MUL`  
- no value is pushed

---

## 4. Operational Semantics

Let:

- `x1, x2 ∈ ℤ₃₂` (signed 32-bit integer domain),  
- multiplication performed in `ℤ₆₄`.

Define:

```
p = x1 × x2
```

Consensus rule:

```
If -2³¹ ≤ p ≤ 2³¹ − 1:
      push(p)
Else:
      fail with SCRIPT_ERR_MUL
```

This behavior is fully deterministic and consistent across architectures.

---

## 5. Execution Algorithm (Reference Pseudocode)

```text
OP_MUL:

1. if stack.size < 2:
       return SCRIPT_ERR_INVALID_STACK_OPERATION

2. x2 ← pop()
   x1 ← pop()

3. v1 ← CScriptNum(x1, 4 bytes)
   v2 ← CScriptNum(x2, 4 bytes)

4. p64 ← int64(v1) * int64(v2)

5. if p64 < INT32_MIN or p64 > INT32_MAX:
       return SCRIPT_ERR_MUL

6. push( CScriptNum(p64, 4 bytes) )
7. continue execution
```

This algorithm constitutes the canonical reference behavior.

---

## 6. Error Conditions

| Condition                           | Error Code                           |
|------------------------------------|---------------------------------------|
| insufficient stack elements         | `SCRIPT_ERR_INVALID_STACK_OPERATION` |
| non-canonical numeric encoding      | `SCRIPT_ERR_NUMERIC` (inherited)     |
| overflow or underflow               | `SCRIPT_ERR_MUL`                     |
| malformed script                    | standard Script errors                |

---

## 7. Domain Summary

### 7.1 Input Domain

```
D_in = ℤ₃₂ × ℤ₃₂
```

### 7.2 Output Domain

```
D_out = ℤ₃₂
```

Results outside ℤ₃₂ produce immediate script failure.

---

## 8. Stack Transformation Rule

```
OP_MUL :  (x1, x2) ↦ (p)
```

Where:

- `p = x1 × x2` if `p` lies within ℤ₃₂  
- otherwise → failure (no value is pushed)

---

## 9. Canonical Encoding Requirements

`CScriptNum(4 bytes)` enforces:

- minimal encoding,  
- no redundant sign byte,  
- no leading zeros,  
- rejection of non-canonical representations.

These rules ensure consistent interpretation across nodes and architectures.

---

## 10. Determinism Requirements

`OP_MUL` **MUST**:

1. produce identical results on all architectures;  
2. reject all overflows deterministically;  
3. perform multiplication using a 64-bit intermediate domain;  
4. push only canonical 32-bit results;  
5. avoid undefined CPU or compiler behavior.

These constraints are consensus-critical.

---

## 11. Test Coverage Summary

Required classes of test cases include:

- valid multiplications,  
- zero multiplication,  
- negative × negative,  
- boundary limits (±1, ±2³¹−1),  
- overflow scenarios,  
- P2SH and regtest end-to-end validation.

(Additional detail in `testing.md`.)

---

## 12. Status and Applicability

This specification is intended for:

- academic research,  
- interpreter experimentation,  
- Script opcode design studies,  
- evaluation of arithmetic safety in consensus-critical systems.

It does **not** represent a proposal for mainnet activation.

---

## 13. Conclusion

`OP_MUL` introduces a deterministic, explicitly specified multiplication operator for Bitcoin Script, consistent with all consensus invariants enforced by Bitcoin Core.  
By defining exact operand domains, encoding rules, failure modes, and stack semantics, this specification ensures rigorous and reproducible behavior.
