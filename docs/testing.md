# Testing Strategy for the OP_MUL Opcode

This document provides a formal description of the testing methodology employed to validate the correctness, safety, and determinism of the `OP_MUL` implementation in Bitcoin Core.

A combination of **unit tests**, **functional tests**, and **boundary validation** ensures full coverage of expected behaviors.

---

## 1. Goals of the Testing Process

The testing framework aims to verify:

- correctness of multiplication within the signed 32-bit domain;
- deterministic overflow detection;
- preservation of Bitcoin Script invariants;
- compatibility with the Bitcoin Core testing infrastructure;
- correct propagation of failure conditions.

---

## 2. Unit Tests (C++)

Unit tests are defined in `src/test/script_tests.cpp`.

### Covered Scenarios

1. **Basic multiplication**
   - `2 * 3 = 6`
   - `(-2) * 3 = -6`
   - `0 * x = 0`

2. **Boundary correctness**
   - `INT32_MAX * 1` → valid  
   - `INT32_MIN * 1` → valid

3. **Overflow rejection**
   - `INT32_MAX * 2` → `SCRIPT_ERR_MUL`
   - `INT32_MIN * (-1)` → `SCRIPT_ERR_MUL`

4. **Encoding and stack behavior**
   - Ensures both inputs are consumed and exactly one output is produced.
   - Confirms that failing conditions do not modify the stack.

Unit tests guarantee correctness of the low-level interpreter logic.

---

## 3. Functional Tests (Python)

Functional tests validate `OP_MUL` within a full Bitcoin node using the standard Bitcoin Core testing harness.

### Test Scripts

- `script_op_mul.py`  
  Validates correct arithmetic and boundary behavior.

- `op_mul_numeric_overflow.py`  
  Constructs P2SH scripts that intentionally trigger arithmetic overflow.

### Functional Scenarios

- Execution of valid scripts inside a local regtest node.
- Rejection of invalid transactions containing overflow conditions.
- Validation of interpreter error propagation into RPC responses.
- Automatic skipping when wallet support is unavailable (ensuring portability).

---

## 4. Determinism and Error Propagation

All tests verify:

- deterministic evaluation across runs;
- stable error codes (`SCRIPT_ERR_MUL`);
- correct messaging as defined in `script.cpp`;
- absence of nondeterministic wrap-around behavior.

---

## 5. Reproducing the Tests

Ensure Bitcoin Core is built and accessible in the environment.

### Execute unit tests:

```bash
src/test/test_bitcoin.exe
```

Execute functional tests:
```
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```
6. Conclusion

The testing process provides comprehensive validation of the OP_MUL opcode.
Through layered testing—unit, functional, and boundary checking—the implementation demonstrates deterministic behavior, strict overflow discipline, and full conformity to Bitcoin Core’s semantic requirements.