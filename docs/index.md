---
title: OP_MUL for Bitcoin Core
---

<style>
  body {
    background-color: #111111;
    color: #eeeeee;
  }
  a {
    color: #66b3ff;
  }
  code, pre {
    background-color: #222222;
    border-radius: 4px;
  }
</style>

# OP_MUL for Bitcoin Core

This site documents an implementation of a new opcode in Bitcoin Core:

```text
OP_MUL = 0x95
```

The opcode performs signed 32-bit integer multiplication in Bitcoin Script, with explicit overflow detection.

Contents

Design and rationale

Environment and build instructions

Testing strategy and test cases

Project status

Implementation: complete and tested locally.

Unit tests (C++): all Bitcoin Core tests pass, including a dedicated overflow test.

Functional tests (Python):

script_op_mul.py

op_mul_numeric_overflow.py

Overflow behaviour:

If the product fits in 32 bits: success.

Otherwise: script fails with SCRIPT_ERR_MUL.

For details, see the pages linked above.

---

### `docs/op_mul-design.md`

```markdown
---
layout: default
title: Design and rationale
---

# Design of OP_MUL (0x95)

## 1. Opcode semantics

`OP_MUL` takes two values from the top of the main stack:

```text
... x1 x2 OP_MUL  ->  ... (x1 * x2)
```