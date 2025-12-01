#!/usr/bin/env bash
#
# Helper script to run the functional tests for OP_MUL on Unix-like systems.
# Adjust BITCOIN_CORE_ROOT if necessary.

set -euo pipefail

BITCOIN_CORE_ROOT="${BITCOIN_CORE_ROOT:-$HOME/dev/btc-opmul/bitcoin}"
TEST_DIR="$BITCOIN_CORE_ROOT/test/functional"
PYTHON="${PYTHON:-python3}"

echo "Running OP_MUL functional tests..."
echo "Bitcoin Core root: $BITCOIN_CORE_ROOT"
echo

cd "$BITCOIN_CORE_ROOT"

"$PYTHON" "$TEST_DIR/script_op_mul.py"
"$PYTHON" "$TEST_DIR/op_mul_numeric_overflow.py"
