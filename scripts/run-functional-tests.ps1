~~~powershell
<# 
.SYNOPSIS
    Executes the OP_MUL functional tests for a Bitcoin Core build.

.DESCRIPTION
    This script locates the functional test directory and runs:
      - script_op_mul.py
      - op_mul_numeric_overflow.py

    It assumes the repository root is the parent directory of this script.
#>

# Resolve repository root
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $ScriptRoot
$TestDir    = Join-Path $RepoRoot "test\functional"

Write-Host "== OP_MUL Functional Test Runner ==" -ForegroundColor Cyan
Write-Host "Repository root: $RepoRoot"
Write-Host "Functional test directory: $TestDir"
Write-Host ""

# Ensure Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python was not found in PATH."
    exit 1
}

# Test scripts
$Tests = @(
    "script_op_mul.py",
    "op_mul_numeric_overflow.py"
)

foreach ($Test in $Tests) {
    $TestPath = Join-Path $TestDir $Test

    if (-not (Test-Path $TestPath)) {
        Write-Error "Test script not found: $TestPath"
        exit 1
    }

    Write-Host "`nRunning: $Test" -ForegroundColor Yellow
    python $TestPath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Test failed: $Test"
        exit 1
    }
}

Write-Host "`nAll OP_MUL functional tests completed successfully." -ForegroundColor Green
~~~
