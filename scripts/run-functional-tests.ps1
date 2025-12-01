<#
.SYNOPSIS
  Helper script to run the functional tests for OP_MUL on Windows.

.DESCRIPTION
  Adjust the paths below to match your local Bitcoin Core build.
#>

param(
    [string]$BitcoinCoreRoot = "C:\Dev\btc-opmul\bitcoin",
    [string]$BuildConfig     = "Release"
)

$testDir = Join-Path $BitcoinCoreRoot "test\functional"
$python  = "python"  # or full path to your virtualenv python if needed

Write-Host "Running OP_MUL functional tests..."
Write-Host "Bitcoin Core root:" $BitcoinCoreRoot
Write-Host "Build configuration:" $BuildConfig
Write-Host ""

Push-Location $BitcoinCoreRoot

# Example: run the two dedicated test files
& $python "$testDir\script_op_mul.py"
& $python "$testDir\op_mul_numeric_overflow.py"

Pop-Location
```bash
python test/functional/script_op_mul.py
python test/functional/op_mul_numeric_overflow.py
```
