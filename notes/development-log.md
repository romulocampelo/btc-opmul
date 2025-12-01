# Development log for OP_MUL

This file records the main steps taken during the development and testing
of the `OP_MUL` implementation.

---

## Environment

- OS: Windows 11
- Toolchain: MSVC 2022 + CMake
- Bitcoin Core: clean build from `master`
- Binaries directory:
  - `C:\Dev\btc-opmul\bitcoin\build\bin\Release`

---

## High-level milestones

- Implemented `OP_MUL = 0x95` in `script/interpreter.cpp`.
- Added new error code and message in `script_error.h` and `script.cpp`.
- Updated `script_tests.json` to remove obsolete `MUL` tests.
- Created C++ unit tests for overflow behaviour.
- Created functional tests:
  - `script_op_mul.py`
  - `op_mul_numeric_overflow.py`
- Verified that:
  - valid multiplications are accepted,
  - overflows trigger `SCRIPT_ERR_MUL`,
  - tests skip automatically when wallet RPC is not available.
