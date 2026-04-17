# vcpkg CI Failure Patterns Reference

This reference catalogues common failure patterns found in vcpkg CI failure log artifacts. Use these patterns to triage and classify failures when analyzing build output.

---

## Log File Structure

Each failure log (`*.log`) in the `"failure logs for {triplet}"` artifact contains the full vcpkg install output for a single port. The log typically follows this structure:

```
-- Downloading <url>...
-- Extracting source...
-- Applying patches...
-- Using cached binary package.   ← binary cache hit (may skip build)
-- Building <port>:<triplet>...
-- Configuring...
-- Building...   ← compiler output here
-- Installing...
-- Running tests...   ← if test feature enabled
-- Completed.

error: building <port>:<triplet> failed with: BUILD_FAILED
```

---

## Category 1: Dependency Chain Failures

**Symptom**: The port itself did not fail — a dependency failed first.

**Log indicators:**
```
-- Building dependency-name[core]:x64-windows... failed
error: package dependency-name:x64-windows is not installed
```

or more explicitly:
```
error: building portname:x64-windows failed with: BUILD_FAILED
  ... the dependency 'depname:x64-windows' failed to install
```

**Triage action:**
- Identify the root failing dependency (the one that failed first in the log)
- All other ports in this chain are "downstream casualties"
- Fix the root dependency; downstream failures should resolve automatically
- In the report, list only the root dependency as a regression; collapse others with a note

**How to find the root:**
- Sort failure logs by time or by name
- A port whose own build commands (not just dependency resolution) fail is the root
- If `portA.log` shows `error: package portB is not installed` and `portB.log` shows actual compiler output, portB is the root

---

## Category 2: CMake Configuration Failures

**Symptom**: `cmake --build` stage fails before any source is compiled.

**Log indicators:**
```
CMake Error at CMakeLists.txt:42 (find_package):
  By not providing "FindXYZ.cmake" in CMAKE_MODULE_PATH this project has
  requested CMake to find a package configuration file provided by "XYZ",
  but CMake did not find one.

CMake Error: Could not find a package configuration file provided by "XYZ"
  with any of the following names:
    XYZConfig.cmake
    xyz-config.cmake
```

**Common root causes:**
- A dependency is not exposing its CMake targets correctly
- A port's `vcpkg.cmake` or `vcpkg-cmake-config` integration is broken
- A `find_package()` call in the upstream CMakeLists.txt uses a non-standard config name

**Other CMake configure patterns:**
```
-- The CXX compiler identification is unknown   ← toolchain issue (rare in CI)
CMake Error: Generator: ... not found          ← MSBuild/Ninja not available
CMake Error (cmake_policy): ...                ← policy violation
```

---

## Category 3: Compiler Errors

**Symptom**: Source code fails to compile.

### MSVC (Windows)
```
error C2065: 'identifier': undeclared identifier
error C2039: 'member': is not a member of 'class'
error C3861: 'function': identifier not found
error C4996: 'function': This function may be unsafe   ← treated as error with /WX
fatal error C1083: Cannot open include file: 'header.h'
```

### Clang (macOS, Linux)
```
error: use of undeclared identifier 'name'
error: no member named 'member' in 'class'
error: 'header.h' file not found
error: unknown type name 'type_name'
```

### GCC (Linux)
```
error: 'name' was not declared in this scope
error: invalid use of incomplete type
error: 'header.h': No such file or directory
```

**Root cause categories:**
- **C++ standard incompatibility**: Code uses features not available in the configured standard (C++14/17/20)
- **Missing Windows includes**: `#include <windows.h>` missing or wrong order
- **API deprecation**: Uses a function/class removed in a newer version of a dependency
- **Compiler flag conflict**: vcpkg sets `-Werror` or `/WX`; warning-as-error triggers on upstream code

**Suggested fix guidance for API deprecation failures:**
When a dependency update removes or renames an API that downstream ports still use:
1. Update the downstream port to a version compatible with the new API
2. Patch the downstream port's source to adapt to the new API
- **Do NOT suggest adding a `<=` version constraint** — vcpkg only supports `>=` version constraints; upper-bound pinning is not possible

---

## Category 4: Linker Errors

**Symptom**: Compilation succeeds but linking fails.

### MSVC
```
error LNK2019: unresolved external symbol "__declspec(dllimport) ..." referenced in function "..."
error LNK2001: unresolved external symbol
error LNK1120: N unresolved externals
```

### GCC/Clang
```
undefined reference to `function_name'
ld: symbol(s) not found for architecture arm64
```

**Root cause categories:**
- **Missing `__declspec(dllexport)`**: Library exports are missing for DLL builds
- **Static vs. dynamic mismatch**: Port links against static lib but needs dynamic (or vice versa)
- **Missing dependency in vcpkg.json**: Library calls into another library not declared as a dependency
- **Symbol visibility**: On Linux/macOS, symbols not exported with `__attribute__((visibility("default")))`

---

## Category 5: SHA512 Hash Mismatch

**Symptom**: Download succeeds but hash verification fails.

```
error: File does not have the expected hash:
          url: https://github.com/owner/repo/archive/v1.2.3.tar.gz
        expected: abc123...
          actual: def456...
```

**Root causes:**
- **Upstream archive changed**: The upstream author re-tagged or replaced the release archive (mutable tags, force-push)
- **Mirror cache stale**: vcpkg asset cache has an old version of the file
- **Port hash not updated**: A PR updated the version but forgot to recalculate SHA512

**Triage action**: Recalculate hash with:
```bash
vcpkg install portname --no-binarycaching
```
The error message will contain the correct new hash.

---

## Category 6: Download / Network Failures

**Symptom**: vcpkg cannot download the source archive.

```
error: Failed to download https://example.com/archive.tar.gz
error: curl: (22) The requested URL returned error: 404
error: curl: (6) Could not resolve host: example.com
```

**Root causes:**
- **URL moved**: Upstream deleted or moved the release (common with GitHub releases being retracted)
- **CI network issue**: Transient connectivity problem (likely if only 1–2 ports fail this way, or a retry succeeds)
- **Domain changed**: Package moved to a new hosting location

**Triage action**: Check if the URL is still valid. If transient, re-run the build.

---

## Category 7: Post-Build Check Failures

**Symptom**: Build and install succeed, but vcpkg's post-install checks fail. Reported as `POST_BUILD_CHECKS_FAILED` in the REGRESSION line.

```
error: The following files are not installed:
    share/portname/copyright

error: Found forbidden pattern in installed file:
    include/portname/config.h: #define PORTNAME_EXPORTS

error: Usage of deprecated vcpkg function 'vcpkg_apply_patches'
```

**Common post-build checks and their fixes:**

| Check | Warning message | Correct fix |
|---|---|---|
| **Misplaced CMake config files** | `This port installs CMake files in places CMake files are not expected` | Fix `vcpkg_cmake_config_fixup()` — use the correct `PACKAGE_NAME` matching the upstream CMake export name (not necessarily the vcpkg port name), and set `CONFIG_PATH` to where the upstream installs its config (e.g., `lib/cmake/pkgname`) |
| **`lib/cmake` not merged** | `should be merged and moved to share/${PORT}/cmake` | Fixed by correcting `vcpkg_cmake_config_fixup()` as above |
| **Usage file not installed** | `this port contains a file named "usage" but didn't install it` | Add `file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")` |
| **Mismatched debug/release binaries** | `mismatching number of debug and release binaries` | Ensure the port builds both debug and release. Do **not** fix by adding `VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES` or `VCPKG_BUILD_TYPE release` (see portfile anti-patterns below) |
| **Missing copyright** | `share/portname/copyright not found` | Add `vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")` with the correct filename and case |
| **Absolute paths in CMake files** | `absolute path found in CMake config` | Use `vcpkg_cmake_config_fixup()` which handles path rewriting |
| **No `.pdb` in release** | `.pdb files in release packages` | Ensure PDB files only install for debug configuration |

**Portfile anti-patterns (do NOT recommend as fixes):**
- `set(VCPKG_BUILD_TYPE release)` — only appropriate for **header-only** libraries. Ports producing binaries (`.lib`, `.a`, `.dll`, `.so`) must build both debug and release.
- `set(VCPKG_POLICY_* enabled)` — policy overrides are escape hatches for exceptional cases. The correct fix is to resolve the underlying issue, not suppress the warning.

**Key insight for `vcpkg_cmake_config_fixup()`**: The `PACKAGE_NAME` argument must match the **upstream CMake export name** (what `find_package()` looks for), which is often different from the vcpkg port name. For example, a port named `minecraft-server-status` whose upstream exports `minecraft_api` needs `vcpkg_cmake_config_fixup(PACKAGE_NAME "minecraft_api" CONFIG_PATH "lib/cmake/minecraft_api")`.

---

## Category 8: Test Failures

**Symptom**: The port itself builds and installs successfully, but its tests fail.

```
Test #1: my_test ...  FAILED
The following tests FAILED:
    1 - my_test (Failed)
```

or in xUnit format (from test results API):
```xml
<testcase name="portname:x64-windows" ...>
  <failure message="Test failed: ..." />
</testcase>
```

**Triage action:**
- Check whether the test passes on other triplets (may be platform-specific)
- Check if this is a flaky test (re-run to confirm)
- Check if the test was previously failing (baseline)

---

## Category 9: Formatting / Manifest Check Failures

**Symptom**: The `"format.diff"` artifact is present and non-empty.

This is not a port build failure but a CI check failure. The `format.diff` artifact contains a unified diff showing:
- `vcpkg.json` manifest files that need formatting via `vcpkg format-manifest`
- Baseline files (`ci.baseline.txt`) that need formatting via `vcpkg format-feature-baseline`
- Version database files that need updating via `vcpkg x-add-version`

**Triage action**: Apply the diff, or run the formatting commands locally:
```bash
./vcpkg format-manifest --all
./vcpkg format-feature-baseline scripts/ci.baseline.txt
./vcpkg x-add-version --all
```

---

## Category 10: Build Timeout

**Symptom**: Job exceeds the 2-day timeout limit (rare).

```
##[error]The job running on agent ... has exceeded the maximum execution time of 2880 minutes.
```

**Triage action**: Almost always an infinite loop or hang in the build system. Check the last lines of the log for the hanging operation.

---

## Category 11: File Conflicts

**Symptom**: The port installs files that conflict with files already installed by another port. This failure is **only visible in the "Test Modified Ports" step log** — it does NOT produce a failure log artifact.

```
REGRESSION: kf6i18n:x64-windows failed with FILE_CONFLICTS. If expected, add kf6i18n:x64-windows=fail to .../ci.baseline.txt.
```

The error in the step log reads (before the REGRESSION summary line):
```
error: File conflicts:
  C:\path\to\installed\x64-windows\bin\some-tool.exe  →  installed by portA and portB
  C:\path\to\installed\x64-windows\include\shared.h   →  installed by portA and portB
```

**Where to find it**: In the "*** Test Modified Ports" task log for the affected job (not in any artifact ZIP).

**Triage action**:
- Identify which two ports are claiming the same installed files
- Usually caused by: a new port that duplicates files from an existing one, or a port that started installing an additional binary that conflicts
- Fix: rename the conflicting file, split the port, or add `conflicts` to the port manifest

---

## Category 12: Missing From Baseline (Unexpected Pass)

**Symptom**: A port that is listed as `fail` in `ci.baseline.txt` now passes. This is reported as a regression only in the step log:

```
REGRESSION: portname:x64-windows failed with MISSING_FROM_BASELINE.
```

**Triage action**: Remove the `portname=fail` entry from `scripts/ci.baseline.txt` — the port is fixed.

The file `scripts/ci.baseline.txt` in the repository root controls which ports are expected to fail.

**Format:**
```
# Comment lines start with #
portname=fail       # will skip in PR CI, attempt in scheduled
portname=skip       # never built in CI
portname=pass       # (same as not listed) must succeed
```

**Triplets covered by CI baseline:**
- `arm-neon-android`
- `arm64-android`
- `arm64-osx`
- `arm64-windows`
- `arm64-windows-static-md`
- `x64-android`
- `x64-linux`
- `x64-osx`
- `x64-uwp`
- `x64-windows`
- `x64-windows-release`
- `x64-windows-static`
- `x64-windows-static-md`
- `x86-windows`

**Important**: Baseline entries apply to all triplets unless a triplet-specific entry exists (not currently supported; all triplet failures for a port use the same baseline entry).

---

## Category 13: Case-Sensitivity Path Failures (Linux/Android only)

**Symptom**: A file-not-found error occurs on Linux and Android triplets, but the same port builds successfully on Windows and macOS.

```
CMake Error at scripts/cmake/vcpkg_install_copyright.cmake:21 (file):
  file INSTALL cannot find ".../src/v1.0.0/LICENSE": No such file or directory.
```

**Root cause**: The portfile references a filename with different casing than the actual file in the upstream repository. Linux and Android use case-sensitive file systems (`LICENSE` ≠ `License` ≠ `license`), while Windows and macOS are case-insensitive and will resolve any casing variant.

**Common occurrences:**
- License files: `LICENSE` vs `License` vs `license` vs `COPYING`
- README files: `README.md` vs `Readme.md` vs `readme.md`
- Source directories with inconsistent casing

**Diagnostic clue**: If a port fails with BUILD_FAILED on all Linux/Android triplets but succeeds (or fails for a *different* reason like POST_BUILD_CHECKS_FAILED) on Windows/macOS, check for a case mismatch in file paths used in the portfile.

**Fix**: Correct the filename in `portfile.cmake` to match the exact casing in the upstream repository. Verify by checking the upstream repo's file listing.

---

## Regression Severity Levels

Use these levels when reporting failures:

| Level | Criteria | Action |
|---|---|---|
| 🔴 **Critical** | Core port (boost, openssl, curl, zlib, cmake) or many dependents fail | Immediate fix required |
| 🟠 **High** | Popular port fails on multiple triplets | Fix before merge |
| 🟡 **Medium** | Single port fails on 1–2 triplets | Fix or add to baseline |
| 🟢 **Low** | Port already in baseline, or transient failure | No immediate action |
| ℹ️ **Info** | Formatting/version file issues | Easy to fix with automated tools |

---

## Common vcpkg CI Triplet Notes

| Triplet | Notes |
|---|---|
| `x64-windows` | Most common; MSVC, dynamic linking |
| `x64-windows-static` | MSVC, static linking (`/MT`) |
| `x64-windows-static-md` | MSVC, static linking (`/MD`) |
| `arm64-windows` | Cross-compiled on x64 Windows; run tests on separate ARM hardware |
| `x64-linux` | Ubuntu in Docker; GCC or Clang |
| `arm64-linux` | Ubuntu ARM64 in Docker |
| `arm64-osx` | macOS ARM (Apple Silicon); Clang |
| `x64-osx` | macOS x86_64; Clang |
| `x64-android` | Cross-compiled; Android NDK Clang |
| `arm64-android` | Cross-compiled; Android NDK Clang |
| `arm-neon-android` | Cross-compiled; Android NDK Clang |
| `x64-uwp` | Universal Windows Platform; WinRT restrictions |
