# Testing Strategy for the OP_MUL Opcode

This document formalizes the testing methodology used to validate the correctness, determinism, and consensus safety of the `OP_MUL` opcode implemented in Bitcoin Core.

A layered approach—combining unit tests, functional tests, and boundary-focused validation—ensures comprehensive coverage of both nominal and failure-path behavior.

---

## 1. Objectives of the Testing Process

The testing framework is designed to verify:

- correct multiplication within the signed 32-bit integer domain;
- strict and deterministic overflow detection;
- preservation of Script invariants (stack behavior, encoding rules);
- compatibility with the Bitcoin Core testing framework;
- accurate propagation of failure conditions and error codes;
- reproducibility across architectures and execution environments.

---

## 2. Unit Tests (C++)

Unit tests are implemented in `src/test/script_tests.cpp` and operate directly on the Script interpreter.

### 2.1 Covered Scenarios

1. **Basic Multiplication**
   - `2 * 3 = 6`
   - `(-2) * 3 = -6`
   - `0 * x = 0` for all valid operands

2. **Boundary Correctness**
   - `INT32_MAX * 1` → accepted
   - `INT32_MIN * 1` → accepted

3. **Overflow Rejection**
   - `INT32_MAX * 2` → `SCRIPT_ERR_MUL`
   - `INT32_MIN * (-1)` → `SCRIPT_ERR_MUL`

4. **Stack Behavior and Encoding**
   - Exactly two inputs consumed and one output produced on success
   - Failure paths leave the stack unmodified
   - Canonical encoding rules enforced via `CScriptNum(4 bytes)`

Unit tests validate the semantic core of the opcode under deterministic, isolated conditions.

---

## 3. Functional Tests (Python)

Functional tests validate behavior within a running Bitcoin node, using the standard functional testing harness.

### 3.1 Test Scripts

- **`script_op_mul.py`**  
  Verifies arithmetic correctness, Script evaluation outcomes, and boundary cases.

- **`op_mul_numeric_overflow.py`**  
  Constructs P2SH transactions that deliberately trigger overflow conditions and ensures proper rejection.

### 3.2 Functional Scenarios

- Execution of valid scripts inside a regtest node
- Accurate rejection of invalid scripts and transactions
- Propagation of `SCRIPT_ERR_MUL` into RPC error outputs
- Deterministic execution across runs and across platforms
- Portable behavior: automatic skipping when wallet features are unavailable

Functional tests ensure integration correctness at the node level.

---

## 4. Determinism, Safety, and Error Propagation

All tests jointly verify:

- deterministic computation of `x1 × x2` using 64-bit intermediate arithmetic;
- absence of wrap-around or architecture-dependent overflow behavior;
- consistent issuance of the consensus error `SCRIPT_ERR_MUL`;
- alignment with the error strings defined in `script.cpp`;
- invariance of behavior across multiple test runs and system configurations.

This section guarantees the implementation is consensus-safe and free of nondeterministic arithmetic.

---

## 5. Reproducing the Tests

Ensure Bitcoin Core is compiled and accessible.

### 5.1 Run C++ Unit Tests

```bash
src/test/test_bitcoin.exe
```

### 5.2 Run Functional Tests

```bash
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```

All tests are deterministic and require no external dependencies beyond a working regtest environment.

---

## 6. Conclusion

The testing strategy provides comprehensive assurance of the correctness and safety of `OP_MUL`.  
By combining unit-level assertions, script-level test vectors, and node-level functional testing, the implementation demonstrates fully deterministic behavior, strict overflow discipline, and complete adherence to Bitcoin Core’s consensus semantics.