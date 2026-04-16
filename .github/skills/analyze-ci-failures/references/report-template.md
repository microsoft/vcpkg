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
10. **Priority levels**:
   - 🔴 **Immediate** — Core/popular ports, failures on 3+ triplets, or CI-environment regressions affecting many ports
   - 🟠 **High** — Failures on 2+ triplets, popular ports, or clear upstream API breaks
   - 🟡 **Medium** — Single-triplet failures with clear fixes
   - ℹ️ **Baseline/Investigate** — Expected failures, environment issues, or unclear root cause

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
