# vcpkg CI Failure Report Template

This file provides the canonical output format for the `analyze-ci-failure` skill.
Use it as the exact template when generating reports.

---

## Report Format

```markdown
# vcpkg CI Failure Report — Build #{buildId}

**Build:** [{buildNumber}]({build_web_url}) · `{definition_name}`
**Triggered by:** {reason} on `{sourceBranch}` @ `{sourceVersion[:8]}`
**Duration:** {startTime} → {finishTime} UTC (~{duration})
**Result:** ❌ **FAILED** — {baseline_summary}

<!-- For PR builds: include a line linking to the PR with its title and author, e.g.:
**PR:** [#51202](https://github.com/microsoft/vcpkg/pull/51202) — `[ltla-cppirlba] Update to 3.1.0` by @xiaozhuai
-->

---

## Summary

| Triplet | Unique Failures |
|---------|----------------|
| x64-windows | N |
| x64-windows-release | N (identical to x64-windows / N unique) |
| x64-linux | N (M shared with Windows) |
| {other triplets} | *artifacts present (not analyzed)* |

**Total unique failing ports across all analyzed triplets: N**
**Estimated cross-platform failures: ≥N ports fail on multiple triplets**

---

## 🔴 Cross-Platform Regressions (Windows + Linux)

### N. `port-name` — Short Root Cause Title

- **Triplets:** x64-windows, x64-windows-release, x64-linux
- **Error:** `exact error message from log`
  in `path/to/file.ext:line`
- **Root cause:** Explanation of why this happened — what changed, what broke.
- **Suggested fix:** Concrete actionable recommendation.

  ```cmake
  # Code snippet if applicable
  ```

---

## 🔴 Windows-Only Regressions

### N. `port-name` — Short Root Cause Title

- **Triplets:** x64-windows, x64-windows-release
- **Error:** `exact error message`
- **Root cause:** ...
- **Suggested fix:** ...

---

## 🔴 Linux-Only Regressions

### N. `port-name` — Short Root Cause Title

- **Triplet:** x64-linux
- **Error:** `exact error message`
- **Root cause:** ...
- **Suggested fix:** ...

---

## 📋 Action Recommendations

| Priority | Port(s) | Recommended Action |
|---|---|---|
| 🔴 Immediate | `port` | Short action description |
| 🟠 High | `port` | Short action description |
| 🟡 Medium | `port` | Short action description |
| ℹ️ Baseline | `port` | Add `=fail/skip # reason` to `ci.baseline.txt` |
| ℹ️ Investigate | `port` | What to look into |
```

---

## Real-World Example (Build #129315)

The following is a real report generated for the scheduled master build on 2026-03-30.
Use this as a reference for tone, depth, and structure.

### Build Metadata

- **Build:** [20260330.1](https://dev.azure.com/vcpkg/public/_build/results?buildId=129315)
- **Reason:** Scheduled run on `refs/heads/master` @ `c4de8d6f`
- **Duration:** ~35 hours
- **Artifacts with failure logs:** all 13 triplets had failures

### Failure Inventory

| Port | Triplets | Root Cause Category | Severity |
|------|----------|---------------------|----------|
| `v8` | win | Python 3.13 removed `pipes` module | 🔴 Immediate |
| `onnxruntime` | win, linux | CMake `math()` on empty TensorRT variable | 🔴 Immediate |
| `wpilib` | win, linux | `wpi::Logger::Log` API mismatch in `DataLog.cpp` | 🔴 Immediate |
| `ntf-core` | win, linux | `bal` dep ordering (win); missing UFID cmake file (linux) | 🟠 High |
| `rmqcpp` | win, linux | Transitive `libpcre2-8` not found via `bal→bdl` | 🟠 High |
| `azure-storage-cpp` | linux | Boost.ASIO `deadline_timer` removed | 🟠 High |
| `cppcoro` | linux | `<experimental/coroutine>` removed in GCC 14 | 🟠 High |
| `zookeeper` | win, linux | Java not found at configure time | 🟡 Medium |
| `moos-essential` | win | POSIX socket headers + Winsock2 conflict | 🟡 Medium |
| `libxt` | win | Clang `-Wunsafe-buffer-usage` promoted to error | 🟡 Medium |
| `saucer` | linux | Upstream compiler version check too strict | 🟡 Medium |
| `libaiff` | linux | Missing `#include <stdint.h>` in public header | 🟡 Medium |
| `libhdfs3` | linux | `mode` macro conflict + missing `<stdint.h>` | 🟡 Medium |
| `yubico-piv-tool` | linux | Clang-only flag `-Wshorten-64-to-32` passed to GCC | 🟡 Medium |
| `libnick` | linux | `sqlcipher` not available via pkg-config | 🟡 Medium |
| `salome-medcoupling` | linux | Missing `metis` vcpkg dependency | 🟡 Medium |
| `mesa` | linux | `glslangValidator` not found by Meson | 🟡 Medium |
| `crashpad` | linux | Compiler not found (exit code 127, likely Docker image change) | ℹ️ Investigate |
| `arrayfire` | linux | Build truncated at 117/832 — likely OOM kill | ℹ️ Investigate |
| `xbitmaps` | linux | `xorg-macros < 1.20` in Docker image | ℹ️ Investigate |
| `nana` | linux | CMake generate fails, no detail in logs | ℹ️ Investigate |
| `openslide` | win | Portfile explicitly rejects MSVC (`use clang-cl`) | ℹ️ Baseline |
| `openzl` | win | Portfile explicitly rejects MSVC (`use clang-cl`) | ℹ️ Baseline |
| `ms-gdkx` | win | Requires Microsoft GDK Xbox Extensions (not in CI) | ℹ️ Baseline |

---

## Formatting Rules

1. **Section order**: Cross-Platform → Windows-Only → Linux-Only → macOS-Only → Android-Only → Action Table
2. **Numbering**: Sequential across all sections (1, 2, 3 … N)
3. **Error quotes**: Always quote the exact first meaningful error line from the log verbatim
4. **Triplet notation**: Use short forms in narrative (`win`, `linux`) but full names in bullet points (`x64-windows`)
5. **Baseline ports**: Ports that explicitly reject a platform by design (`MSVC is not supported`, environment requirements) go to the Baseline section, not regressions
6. **Dependency chain**: If port A fails because port B failed, list only port B as the regression with a note "causes N downstream failures: portA, portC, …"
7. **Transient failures**: Download failures (curl errors, SHA mismatches) and exit-code-127 failures should be flagged as potentially transient
8. **Version constraints**: Never suggest adding a `<=` version constraint as a fix — vcpkg only supports `>=` constraints. For API-breaking dependency updates, suggest updating the consuming port or patching it instead.
9. **PR context**: For PR-triggered builds, always include a link to the PR, the PR title, and the author in the report header.
10. **Portfile anti-patterns**: Never recommend `set(VCPKG_BUILD_TYPE release)` for ports that produce binaries — it is only for header-only libraries. Never recommend adding `VCPKG_POLICY_*` overrides to suppress post-build check warnings — fix the underlying issue instead. Most ports should not set any policy variable.
11. **Case-sensitivity**: When a file-not-found error occurs only on Linux/Android but the port passes on Windows/macOS, always verify the exact filename casing in the upstream repository before concluding the file is missing.
12. **`vcpkg_cmake_config_fixup` package name**: The `PACKAGE_NAME` argument must match the upstream CMake export name (what consumers pass to `find_package()`), which may differ from the vcpkg port name.
13. **Priority levels**:
   - 🔴 **Immediate** — Core/popular ports, failures on 3+ triplets, or CI-environment regressions affecting many ports
   - 🟠 **High** — Failures on 2+ triplets, popular ports, or clear upstream API breaks
   - 🟡 **Medium** — Single-triplet failures with clear fixes
   - ℹ️ **Baseline/Investigate** — Expected failures, environment issues, or unclear root cause
14. **Feature baseline unexpected passes**: When a job fails without REGRESSION lines, always scan the step log for `"passed but was marked expected to fail"` from `ci.feature.baseline.txt`. Report these under a separate "🟡 Unexpected Passes (Baseline Cleanup Required)" section, not as regressions or unrelated failures. The fix is to remove the stale entry from `scripts/ci.feature.baseline.txt`.
15. **Android-specific macro collisions**: When a port fails only on Android with syntax errors and the compiler note says `"expanded from macro"` pointing to an NDK system header, this is a macro name collision — not a code bug in the traditional sense. Report it as an Android-specific issue with the fix being to rename the conflicting identifier upstream.
16. **C++26 transitive include issues**: When a port compiles with `-std=c++2c` and fails on Clang/libc++ (macOS, Android) but passes on MSVC/GCC, suspect missing standard library includes that were previously available transitively. Check the compile command for the C++ standard flag.
17. **Version validation failures**: When the "Validate version files" task fails, report it as a separate issue (not a build regression). The fix is always `vcpkg x-add-version {portname}`. No failure log artifacts are produced for this failure type.
18. **Feature baseline coverage gaps**: When feature tests fail on multiple triplets but `ci.feature.baseline.txt` only covers some, explicitly list which triplets are missing entries and recommend expanding the baseline. Don't just say "update the baseline" — show which entries need to be added.
19. **Debug/release CRT mismatch**: When a port fails on all Windows triplets except `x64-windows-release` with `LNK2038` runtime library mismatch errors, the root cause is host tools (code generators) mixing debug and release objects. Recommend using `OPTIONS_RELEASE`/`OPTIONS_DEBUG` in `vcpkg_cmake_configure()` to restrict tool building to the release configuration.

---

## Artifact Size Heuristics

Use artifact sizes (from the artifacts list API response) to prioritize analysis:

| Artifact Size | Interpretation |
|---|---|
| < 10 MB | Very few failures (< ~15 ports), analyze fully |
| 10–50 MB | Moderate failures (~15–80 ports), sample representative ones |
| 50–120 MB | Many failures (~80–200 ports), focus on unique errors only |
| > 120 MB | Mass failures — likely a systemic issue (toolchain, CI image, common dep) |

In build #129315, x64-windows (8.5 MB) and x64-linux (4.6 MB compressed) were small enough for complete analysis.
Android artifacts (~115–123 MB) indicate widespread failures likely sharing a common root cause.

---

## Common Root Cause Patterns to Look For First

When analyzing a new build, scan for these high-frequency patterns before deep-diving individual ports:

| Pattern | Indicator in logs | Likely cause |
|---|---|---|
| `No module named 'pipes'` or similar Python import error | Python stdlib change | Python version upgrade on CI |
| `fatal error: experimental/coroutine` | Many Linux ports | GCC 14 / compiler image upgrade |
| `deadline_timer` / `posix_time` | Boost-dependent ports | Boost.ASIO API break |
| `error: unrecognized command-line option` | Configure-time test | Wrong compiler flags for toolchain |
| `FAILED: [code=127]` | Many compilation units | Compiler not in PATH (Docker image change) |
| `math cannot parse the expression: ""` | CMake configure | Empty variable in math() — missing guard |
| `Cannot open include file: 'sys/socket.h'` | Win + POSIX code | Missing WIN32 socket porting |
| `must install xorg-macros` | autotools ports | CI image missing xorg-dev package |
| Build truncated, no error message | OOM or timeout | Use `DISABLE_PARALLEL` or check resources |
| Many ports → same dependency fails | dep chain | Find root dep; rest are downstream casualties |
| `passed but was marked expected to fail` | Job exit code 1, no REGRESSION lines | Stale `ci.feature.baseline.txt` entry — remove it |
| `error: expected ')'` + `expanded from macro` on Android | Android NDK macro collision | POSIX signal macros (`si_value`, etc.) clash with code identifiers |
| `no member named 'X' in namespace 'std'` + `-std=c++2c` | Clang/libc++ C++26 mode | Missing `#include` — transitive includes removed in C++26 |
| `was not found in versions database` or `baseline.json: error: ... is assigned M, but the local port is N` | Version validation task | PR didn't run `vcpkg x-add-version` — no port builds attempted |
| `Could not find GO_BIN` or `mkdir /go: permission denied` | Go-dependent features | Go not available/writable in CI — mark features as `feature-fails` |
| Feature tests fail on triplets not in `ci.feature.baseline.txt` | Job exit code 1, no REGRESSION lines | Feature baseline entries only cover some triplets — expand them |
| `LNK2038: mismatch detected for 'RuntimeLibrary'` or `'_ITERATOR_DEBUG_LEVEL'` | MSVC debug build, passes on release-only triplet | Debug/release CRT mismatch in host tools — use `OPTIONS_RELEASE` to build tools only in release |
