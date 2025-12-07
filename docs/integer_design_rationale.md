# Design Rationale and Arithmetic Patterns

## Why No Floating-Point Support?

A common question regarding arithmetic extensions in Bitcoin Script is the absence of floating-point support (IEEE 754). This implementation of `OP_MUL` strictly adheres to 32-bit signed integers (`CScriptNum`) for the following reasons:

### 1. Consensus and Determinism
Bitcoin requires absolute consensus. Every node, regardless of hardware architecture (x86, ARM, RISC-V) or compiler version, must produce the exact same result for every transaction. Floating-point arithmetic is notoriously non-deterministic across different platforms due to subtle differences in rounding modes and precision handling. A divergence of a single least-significant bit would cause a hard fork.

### 2. Associativity and Precision
In floating-point arithmetic, `(a + b) + c` is not always equal to `a + (b + c)` due to precision loss. In financial ledgers, associativity is critical to ensure that the order of operations does not alter the final balance. Integer arithmetic is associative and precise, ensuring that no Satoshis are created or lost due to rounding errors.

### 3. Attack Surface
Implementing a full floating-point standard introduces complex edge cases such as `NaN` (Not a Number), `Infinity`, and `-0`. These cases create significant complexity in the script interpreter, increasing the validation cost and opening new vectors for Denial of Service (DoS) attacks.

---

## Fixed-Point Arithmetic Pattern

Financial calculations requiring decimals (e.g., interest rates, exchange rates) should be implemented using **Fixed-Point Arithmetic** on top of the provided integer opcodes. This shifts the complexity of decimal management to the script layer, keeping the consensus layer simple and robust.

### How it works
To simulate decimals, we use a scaling factor. The basic formula is:
`Result = (Value * Multiplier) / Scale`

### Example: Calculating a 1.5% Fee

**Scenario:** A script requires calculating a fee of 1.5% on a transaction output of 10,000 satoshis.

**Parameters:**
- **Principal:** `10,000`
- **Rate:** `1.5%` -> represented as integer `15` with a scale of `1000` (since 1.5% = 0.015, and 0.015 * 1000 = 15).
- **Scale:** `1000`

**Script Logic:**
```bitcoin
<1000> <15> <10000> OP_MUL OP_DIV
