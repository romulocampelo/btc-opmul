# Environment and Build Instructions for Bitcoin Core (OP_MUL Implementation)

This document describes the complete procedure used to reproduce, compile, and test the Bitcoin Core environment required for the `OP_MUL` opcode implementation.  
All steps follow the official development methodology adopted by the Bitcoin Core project, ensuring reproducibility, determinism, and methodological rigor.

---

## 1. Reference Development Environment

The implementation and experimentation were performed on the following configuration:

- **Operating System:** Windows 11  
- **Toolchain:** Microsoft Visual C++ (MSVC 2022)  
- **Build System:** CMake (multi-generator support)  
- **Bitcoin Core Branch:** `master` (clean checkout)  
- **Python Version:** 3.10+ (required for functional tests)  
- **Additional Tools:** Git, Ninja (optional), Visual Studio Build Tools  

The same procedure applies to Linux or macOS with minimal adjustments.

---

## 2. Cloning Bitcoin Core

Obtain a clean copy of the Bitcoin Core source tree:

```bash
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
```
It is strongly recommended to work on a clean and recent commit before applying modifications.

3. Applying the OP_MUL Patch

Once inside the repository, apply the patch generated for this project:
`git apply path/to/op_mul.diff`
If the patch applies without conflict, the output will be empty.

To verify:
`git status`
You should see modified files such as:

src/script/interpreter.cpp

src/script/script_error.h

src/script/script.cpp

src/test/script_tests.cpp

test functional scripts (added separately)

4. Generating the Build Configuration

On Windows, the recommended process is:
```bash
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Release ..
```
This generates a Visual Studio solution (.sln) containing all compilation targets.

Alternatively, for a faster command-line build:
`cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..`
5. Building Bitcoin Core

If using Visual Studio:

Open the generated .sln file.

Select the Release configuration.

Build the following targets:

bitcoind

bitcoin-cli

bitcoin-tx

If using Ninja: 

`ninja` 

The compiled binaries will be generated (example path):

`bitcoin/build/bin/Release/`
6. Preparing the Functional Test Environment

Bitcoin Core functional tests require:

Python 3 with:

pyzmq

requests

python-bitcoinrpc (automatically included in Bitcoin Core test harness)

Install dependencies:

`pip install -r test/functional/requirements.txt`

Functional tests will automatically detect environment support and skip wallet tests when necessary.

7. Running Unit and Functional Tests
Unit Tests
`src/test/test_bitcoin.exe`

Functional Tests
`python test/functional/script_op_mul.py`
`python test/functional/op_mul_numeric_overflow.py`

8. Conclusion

Following the steps above yields a reproducible, deterministic build of Bitcoin Core containing the OP_MUL implementation. All subsequent testing and evaluation described in this project assumes this environment.


---

