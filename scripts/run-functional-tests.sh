#!/usr/bin/env bash
#
# OP_MUL Functional Test Runner for Bitcoin Core
# Runs:
#   - script_op_mul.py
#   - op_mul_numeric_overflow.py
#
# This script assumes it resides in: scripts/
# and the repository root is its parent directory.

set -e

echo "== OP_MUL Functional Test Runner =="

# Resolve directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$REPO_ROOT/test/functional"

echo "Repository root: $REPO_ROOT"
echo "Functional tests: $TEST_DIR"
echo

# Detect Python
if ! command -v python &>/dev/null; then
    echo "Error: python not found in PATH."
    exit 1
fi

# Test list
TESTS=(
    "script_op_mul.py"
    "op_mul_numeric_overflow.py"
)

# Run tests
for test in "${TESTS[@]}"; do
    TEST_PATH="$TEST_DIR/$test"

    if [[ ! -f "$TEST_PATH" ]]; then
        echo "Error: missing test: $TEST_PATH"
        exit 1
    fi

    echo "Running: $test"
    python "$TEST_PATH"
    echo
done

echo "All OP_MUL functional tests completed successfully."