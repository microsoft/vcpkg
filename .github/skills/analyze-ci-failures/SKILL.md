---
name: analyze-ci-failures
description: 'Analyze vcpkg Azure DevOps CI build failures. Downloads failure logs, identifies regression root causes, and generates a structured report categorizing build errors by package, triplet, and failure type.'
argument-hint: 'Azure DevOps build URL or GitHub PR URL (e.g., "https://dev.azure.com/vcpkg/public/_build/results?buildId=129315" or "https://github.com/microsoft/vcpkg/pull/51134")'
---

# vcpkg CI Failures Analyzer

## When to Use

- Investigating why a CI build failed on Azure DevOps
- Identifying which packages regressed in a PR or scheduled build
- Triaging root causes before assigning bugs or reverting changes
- Getting a quick summary of failures across all triplets in one build

## Overview

This skill fetches build metadata and failure logs directly from the Azure DevOps REST API, cross-references them with `scripts/ci.baseline.txt`, and produces a structured regression report:

- **Build Summary**: Overall build result, trigger type (PR vs scheduled), and which jobs (triplets) failed
- **Artifact Download**: Fetches every "failure logs for *" artifact published by the CI pipeline
- **Log Analysis**: Parses per-package failure logs to extract compiler errors, missing dependencies, linker errors, and other root causes
- **Regression Classification**: Distinguishes new regressions from known failures already listed in `ci.baseline.txt`
- **Structured Report**: Organized by triplet, then package, with concise root-cause summaries

## Detailed Workflow

### Step 1: Parse the Build URL

The skill accepts either an **Azure DevOps build URL** or a **GitHub PR URL** as input.

**Azure DevOps build URL:**
```
https://dev.azure.com/vcpkg/public/_build/results?buildId=129315&view=results
```

Extract:
- **organization**: `vcpkg`
- **project**: `public`
- **buildId**: `129315`

**GitHub PR URL:**
```
https://github.com/microsoft/vcpkg/pull/51134
```

Extract the PR number, then use the GitHub API to find the associated Azure DevOps build:
1. Fetch the PR's check runs: `GET /repos/microsoft/vcpkg/pulls/{pr_number}/check-runs` (use `github-mcp-server-pull_request_read` with method `get_check_runs`)
2. Find the check run named `microsoft.vcpkg.pr` — its `details_url` contains the Azure DevOps build URL with `buildId`
3. Extract the `buildId` from that URL and proceed with the normal workflow

The REST API base is: `https://dev.azure.com/{organization}/{project}/_apis`

### Step 2: Fetch Build Metadata

**Get overall build info:**
```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}?api-version=7.0
```
Key fields in the response:
- `status` — `completed`, `inProgress`, etc.
- `result` — `succeeded`, `failed`, `partiallySucceeded`, `canceled`
- `reason` — `pullRequest`, `schedule`, `manual`, `individualCI`
- `requestedFor.displayName` — who triggered the build
- `sourceBranch` — branch or PR reference (e.g., `refs/pull/51202/merge` for PR builds)
- `sourceVersion` — commit SHA
- `_links.web.href` — canonical link back to the build page
- `finishTime` — when it completed

**For PR-triggered builds** (`reason == "pullRequest"`): extract the PR number from `sourceBranch` (e.g., `refs/pull/51202/merge` → PR #51202). Use the GitHub API to fetch the PR title and author — include these in the report header for context, and link to the PR with `https://github.com/microsoft/vcpkg/pull/{pr_number}`. The PR is on the `microsoft/vcpkg` repository (not `vicroms/vcpkg`).

**Get the build timeline (all jobs and tasks):**
```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/timeline?api-version=7.0
```
The response contains a `records` array. Each record has:
- `type` — `"Job"`, `"Task"`, `"Stage"`, `"Phase"`
- `name` — display name (e.g., `"x64_windows"`, `"*** Test Modified Ports"`)
- `result` — `"succeeded"`, `"failed"`, `"skipped"`, `"canceled"`
- `state` — `"completed"`, `"inProgress"`, `"pending"`
- `log.url` — URL to the raw task log (for individual task logs)
- `parentId` — parent record ID (tasks belong to jobs)

Filter for `type == "Job"` and `result == "failed"` to get a list of failing triplets.

### Step 2b: Scan "Test Modified Ports" Step Logs for REGRESSION Lines

**This step is required** — some failure types (notably `FILE_CONFLICTS`) are only reported in the step console output and do **not** produce entries in the failure log artifacts. Skipping this step will miss those regressions entirely.

For each failed job in the timeline, find the task named `"*** Test Modified Ports"` (type `"Task"`, child of that job) and fetch its log:

```
GET {record.log.url}?api-version=7.0
```

The log is plain text. Scan it for lines matching the pattern:
```
REGRESSION: {port}:{triplet} failed with {FAILURE_TYPE}.
```

**Example output from a real build:**
```
REGRESSION: kf6i18n:x64-windows failed with FILE_CONFLICTS. If expected, add kf6i18n:x64-windows=fail to D:\a\_work\1\s\scripts\azure-pipelines/../ci.baseline.txt.
REGRESSION: kf6itemmodels:x64-windows failed with FILE_CONFLICTS. If expected, add kf6itemmodels:x64-windows=fail to D:\a\_work\1\s\scripts\azure-pipelines/../ci.baseline.txt.
```

**Known `FAILURE_TYPE` values found in this log:**
| Failure type | Also has artifact log? | Notes |
|---|---|---|
| `BUILD_FAILED` | ✅ Yes | Full build logs in "failure logs for {triplet}" artifact |
| `POST_BUILD_CHECKS_FAILED` | ✅ Yes | Build succeeded but vcpkg post-install validation failed (misplaced CMake files, missing usage, etc.) |
| `FILE_CONFLICTS` | ❌ No | Port installs files that conflict with another port; only in step log |
| `MISSING_FROM_BASELINE` | ❌ No | Port passed but is listed as `fail` in baseline; no artifact |
| `CASCADE_BUILD_FAILED` | Sometimes | Dependency failure; root port has artifact, downstream may not |

**PowerShell to extract all REGRESSION lines from a job's "Test Modified Ports" step:**
```powershell
# Get the timeline to find log URLs
$timeline = Invoke-RestMethod "https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/timeline?api-version=7.0"

# For each failed job, find its "Test Modified Ports" task
$failedJobs = $timeline.records | Where-Object { $_.type -eq 'Job' -and $_.result -eq 'failed' }
foreach ($job in $failedJobs) {
    $testTask = $timeline.records | Where-Object {
        $_.type -eq 'Task' -and
        $_.parentId -eq $job.id -and
        $_.name -like '*Test Modified Ports*'
    }
    if ($testTask -and $testTask.log.url) {
        $logText = Invoke-RestMethod "$($testTask.log.url)?api-version=7.0"
        $regressions = $logText -split "`n" | Where-Object { $_ -match '^REGRESSION:' }
        $regressions | ForEach-Object { Write-Host "$($job.name): $_" }
    }
}
```

Collect all `REGRESSION:` lines from all jobs into a master list before proceeding to artifact download. This list is your **ground truth** for what failed — the failure log artifacts are supplementary evidence for diagnosing *why*.

**Important: Also scan for "unexpected pass" errors.** Jobs can fail with exit code 1 and produce **no REGRESSION lines** when a port passes but is marked as expected to fail in `scripts/ci.feature.baseline.txt`. Scan the step log for lines matching:
```
ci.feature.baseline.txt: error: {port}[{features}]:{triplet} passed but was marked expected to fail
```
These indicate stale feature baseline entries that must be removed. Report them in the report under a "🟡 Unexpected Passes (Baseline Cleanup Required)" section.

### Step 3: List Published Artifacts

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/artifacts?api-version=7.0
```
Each artifact in `value[]` has:
- `name` — e.g., `"failure logs for x64-windows"`, `"file lists for x64-windows"`, `"format.diff"`
- `resource.type` — **`"PipelineArtifact"`** (not `"Container"` — the Container listing API does **not** work for these)
- `resource.downloadUrl` — direct ZIP download URL hosted on `artprodwus21.artifacts.visualstudio.com`; no auth required for public builds

**Focus on artifacts whose name starts with `"failure logs for"`** — these contain one subdirectory per failing port.

**Prioritize by compressed artifact size** (from `resource.properties.artifactsize`):

| Compressed size | Interpretation | Analysis depth |
|---|---|---|
| < 10 MB | Few failures (< ~15 ports) | Analyze all ports fully |
| 10–50 MB | Moderate failures | Sample all ports, deep-dive key ones |
| 50–120 MB | Many failures | Focus on unique error categories only |
| > 120 MB | Mass failures — likely a systemic issue | Find the common root, skip per-port deep-dive |

Start with the smallest artifacts (fastest feedback). Android triplets typically produce 115–123 MB artifacts and share root causes with Linux.

### Step 4: Download Failure Log Artifacts

**`web_fetch` cannot download binary ZIP files.** Use PowerShell with `Invoke-WebRequest` instead.

**Output directory:** All downloaded artifacts and the final report are saved in a persistent directory under the repository root for manual review:

```
ci-failure-analysis/
├── pr-51196/           ← PR-triggered build (named by PR number)
│   ├── logs/           ← extracted failure log artifacts
│   │   ├── x64-linux/
│   │   │   └── failure logs for x64-linux/
│   │   │       ├── ffmpeg/
│   │   │       └── ...
│   │   ├── x64-windows-static/
│   │   └── ...
│   └── report.md       ← the generated analysis report
├── ci-130500/          ← scheduled/manual build (named by build ID)
│   ├── logs/
│   └── report.md
└── ...
```

**Naming convention:**
- **PR-triggered builds** (`reason == "pullRequest"`): `pr-{pr_number}` (e.g., `pr-51196`)
- **All other builds** (scheduled, manual, individualCI): `ci-{buildId}` (e.g., `ci-130500`)

This directory is listed in `.gitignore` and will not be committed. It allows reviewers to manually inspect the raw logs alongside the report.

```powershell
# Determine the output directory name
if ($build.reason -eq 'pullRequest') {
    $prNumber = ($build.sourceBranch -replace 'refs/pull/(\d+)/merge','$1')
    $analysisDir = "$repoRoot\ci-failure-analysis\pr-$prNumber"
} else {
    $analysisDir = "$repoRoot\ci-failure-analysis\ci-$buildId"
}
$logsDir = "$analysisDir\logs"
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null

# Download the artifact ZIP using the downloadUrl from the artifacts API response
$downloadUrl = "{resource.downloadUrl from artifacts API}"
Invoke-WebRequest -Uri $downloadUrl -OutFile "$logsDir\{triplet}.zip" -UseBasicParsing

# Extract
Expand-Archive "$logsDir\{triplet}.zip" -DestinationPath "$logsDir\{triplet}" -Force

# Remove the ZIP after extraction to save space
Remove-Item "$logsDir\{triplet}.zip" -Force

# List failed ports — each is a subdirectory inside "failure logs for {triplet}/"
$root = "$logsDir\{triplet}\failure logs for {triplet}"
Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name
```

**Confirmed ZIP structure (from build #129315):**
```
failure logs for x64-windows.zip
└── failure logs for x64-windows/        ← top-level folder = artifact name
    ├── boost-filesystem/                 ← one subdirectory per failing port
    │   ├── stdout-x64-windows.log        ← PRIMARY: full vcpkg output, final error
    │   ├── config-x64-windows-out.log    ← CMake configure stdout
    │   ├── config-x64-windows-err.log    ← CMake configure stderr
    │   ├── config-x64-windows-dbg-CMakeConfigureLog.yaml.log
    │   ├── config-x64-windows-dbg-CMakeCache.txt.log
    │   ├── config-x64-windows-dbg-ninja.log
    │   ├── build-x64-windows-dbg-out.log ← compiler stdout (can be very large)
    │   ├── build-x64-windows-dbg-err.log ← compiler stderr
    │   ├── install-x64-windows-dbg-out.log
    │   ├── install-x64-windows-dbg-err.log
    │   ├── patch-x64-windows-0-err.log   ← patch application errors (numbered)
    │   ├── patch-x64-windows-0-out.log
    │   ├── extract-out.log / extract-err.log
    │   └── generate-x64-windows-dbg-err.log  ← GN builds (v8, crashpad) only
    ├── curl/
    ├── openssl/
    └── ...
```

**For Meson ports (e.g., mesa):**
```
mesa/
├── cmake-get-vars_C_CXX-x64-linux-dbg.cmake.log
├── config-x64-linux-dbg-meson-log.txt.log
├── meson-x64-linux-dbg.log
├── pip-install-packages-x64-linux-err.log
├── venv-setup-x64-linux-err.log
└── stdout-x64-linux.log
```

**For autotools ports (e.g., libxt):**
```
libxt/
├── autoconf-x64-windows-err.log
├── build-x64-windows-dbg-err.log   ← compiler warnings/errors
├── build-x64-windows-dbg-out.log
└── stdout-x64-windows.log
```

**For feature test failures (e.g., arrow-adbc_flightsql):**
```
arrow-adbc_flightsql/
├── issue_body.md          ← markdown summary of the failure (human-readable)
├── tested-spec.txt        ← exact feature combination tested (e.g., "arrow-adbc[core,flightsql]:x64-linux")
├── stdout-x64-linux.log   ← may or may not be present
├── config-x64-linux-*.log ← may or may not be present
└── build-x64-linux-*.log  ← may or may not be present
```

Feature test artifacts use naming suffixes to indicate the feature combination: `portname_cpp`, `portname_all_3`, `portname_flightsql`, etc. The `tested-spec.txt` file always contains the exact `portname[features]:triplet` spec that was tested. The `issue_body.md` contains a markdown-formatted summary including the error output — read this first for quick triage.

### Step 5: Analyze Log Content — Two-Phase Approach

**Phase 1: Classify all failures quickly (one pass)**

For each failing port, read only `stdout-{triplet}.log` last 20 lines:
```powershell
$ports = Get-ChildItem $root -Directory | Sort-Object Name
foreach ($port in $ports) {
    $stdout = Get-ChildItem $port.FullName -Filter "stdout*" | Select-Object -First 1
    if ($stdout) {
        $lines = Get-Content $stdout.FullName -Encoding UTF8
        # Extract final error line
        $keyError = ($lines | Where-Object { $_ -match "error:|CMake Error|FAILED" } | Select-Object -Last 1) -replace '^\s+',''
        Write-Host "$($port.Name): $keyError"
    }
}
```

This gives a one-line classification per port. Identify common patterns across ports (many ports → same error = systemic issue).

**Phase 2: Deep-dive the specific stage log for each port**

After classifying, choose the right log file based on failure type:

| Failure type indicated by stdout | Log to read next |
|---|---|
| `Command failed: cmake --build` (build/install) | `install-{triplet}-dbg-out.log` — grep for `error:` |
| `Command failed: ninja -v` (configure) | `config-{triplet}-out.log` — last 20 lines |
| `Command failed: ninja -v` (configure) | `config-{triplet}-dbg-CMakeConfigureLog.yaml.log` |
| `Command failed: gn gen` or `ninja` (GN) | `generate-{triplet}-dbg-err.log` |
| `Command failed: meson setup` | `config-{triplet}-dbg-meson-log.txt.log` |
| `Command failed: make` (autotools) | `build-{triplet}-dbg-err.log` |
| `Command failed: autoreconf` | `autoconf-{triplet}-err.log` |
| Patch error | `patch-{triplet}-N-err.log` |

**Important**: `install-*-out.log` and `build-*-out.log` can be very large (100KB–2MB+). Always grep for errors rather than reading the full file:
```powershell
$lines = Get-Content "install-x64-windows-dbg-out.log" -Encoding UTF8
$lines | Where-Object { $_ -match "error:" -and $_ -notmatch "^--" } | Select-Object -First 10
```

**Note on empty error logs**: Many `*-err.log` files are empty (0 bytes) — the actual error output goes to stdout for CMake/ninja builds. Always check `*-out.log` if `*-err.log` is empty.

**Note on test results API**: `GET /_apis/test/runs?buildId=...` requires authentication even for public projects. Skip this API; the failure logs contain sufficient information.

### Step 5 (continued): Pattern Catalogue

For each failure log, identify the root cause by scanning for known error patterns.
See `references/vcpkg-failure-patterns.md` for a comprehensive pattern catalogue and `references/report-template.md` for a table of the most common high-frequency patterns to check first.

**Quick triage checklist (scan each log in order):**

1. **Dependency failure** — the port didn't actually fail itself; a dependency did:
   ```
   error: package dependency-name:triplet is not installed
   -- Building dependency-name[core]:triplet failed
   ```
   Root cause: the dependency listed in the log, not the current package.

2. **CMake configure error** — dependency not found or incompatible version:
   ```
   CMake Error: Could not find a package configuration file provided by "XYZ"
   CMake Error at CMakeLists.txt:NN: find_package(XYZ REQUIRED)
   ```

3. **Compiler error** — actual source code compile failure:
   ```
   error C2065:  (MSVC)
   error: use of undeclared identifier  (Clang/GCC)
   fatal error: 'header.h' file not found
   ```

4. **Linker error**:
   ```
   error LNK2019: unresolved external symbol  (MSVC)
   undefined reference to  (GCC/Clang)
   ```

5. **SHA512 mismatch** — downloaded archive hash changed:
   ```
   error: File does not have the expected hash
   Expected: ...
   Actual: ...
   ```

6. **Download failure** — network or URL issue:
   ```
   error: Failed to download
   error: curl: (22)
   ```

7. **Post-build check failure** — installed files don't pass vcpkg checks:
   ```
   error: The following files are not installed
   error: Usage of deprecated function
   ```

8. **Test failure** — port tests failed (check xUnit results):
   ```
   Test failed: ...
   FAILED - ...
   ```

### Step 6: Cross-Reference with CI Baseline

Read **both** baseline files from the local repository to classify each failure:

**`scripts/ci.baseline.txt`** — per-port expected failures:
```
# Format: port-name=fail|skip|pass [# comment]
boost-filesystem=fail  # needs icu update
```

**`scripts/ci.feature.baseline.txt`** — per-feature/triplet expected failures:
```
# Format: port-name(condition)=fail|skip [# comment]
dimcli(windows & static)=fail  # VS2019 PDB issue
portname[feature]:triplet=feature-fails
```

**Classification logic:**
- If the failing port is listed as `fail` or `skip` in either baseline → **Known / Expected** (not a regression)
- If the failing port is NOT in any baseline, or listed as `pass` → **Regression** (new failure)
- If a port that is expected to `fail` is now succeeding → **Unexpected Pass** (baseline entry must be removed)

### Step 7: Generate the Regression Report

Produce a structured markdown report with the following sections:

---

**Template:**

```markdown
# vcpkg CI Failure Report

**Build:** [#{buildId}]({build_web_url})
**Triggered by:** {reason} — {requestedFor} on `{sourceBranch}` @ `{sourceVersion[:8]}`
**Result:** {result} | **Finished:** {finishTime}

---

## Summary

| Triplet | Status | New Regressions | Known Failures |
|---------|--------|-----------------|----------------|
| x64-windows | ❌ Failed | 3 | 1 |
| x64-linux | ✅ Passed | 0 | 0 |
| ... | | | |

---

## 🔴 New Regressions (Action Required)

### x64-windows

#### `portname` — Root Cause Category
- **Error:** `<first relevant error line>`
- **File:** `path/to/file.cpp:42`
- **Analysis:** Short description of why this likely broke.
- **Suggested fix:** ...

...

---

## 🟡 Known / Expected Failures (Baseline)

| Port | Triplet | Baseline Entry |
|------|---------|----------------|
| portname | x64-windows | `fail # reason` |
...

---

## ℹ️ Notes

- Dependency chain failures: {n} ports failed due to a common upstream failure in `dep-name`
- Download failures: {n} (may be transient network issues)
```

---

### Step 8: Dependency Chain Deduplication

Before listing regressions, collapse dependency chains:

- If `libA` fails and `libB`, `libC`, `libD` all fail because `libA` is a dependency, list only `libA` as the regression with a note: "caused {n} downstream failures: libB, libC, libD"
- Check dependency info from the log: lines containing `-- Building {dep}:{triplet} failed` indicate the root of the chain

### Step 9: Transient vs. Persistent Failures

Flag failures that are likely transient (not actual regressions):
- Download failures (network errors, SHA mismatches from upstream file changes)
- Timeout failures (`error: build timed out`)
- Flaky test failures (same port fails in one triplet but passes in others for unrelated reasons)

Suggest re-running the build for transient failures rather than filing issues.

## Quick Start

**Minimal 3-step process:**
1. Provide the build URL: `analyze-ci-failure https://dev.azure.com/vcpkg/public/_build/results?buildId=129315`
2. Skill fetches build metadata, downloads all failure log artifacts, reads baseline
3. Receive structured regression report

## Output Format

When generating the report, follow the exact format defined in `references/report-template.md`.
That file contains:
- The full markdown template with placeholder variables
- A real worked example (build #129315, 24 ports) to calibrate tone and depth
- Formatting rules (section order, priority levels, error quoting style)
- Artifact size heuristics to guide how deeply to analyze each triplet
- A table of common high-frequency patterns to scan for first

When asked to produce the report, default to the full structured markdown report. You can also produce:
- **Summary only**: Just the summary table and count of regressions
- **Regressions only**: Skip known failures, show only new regressions
- **Single triplet**: Focus on one platform (e.g., "x64-windows only")
- **Port-focused**: Group by port name instead of triplet

### Saving the Report

After generating the report, **always save it as `report.md`** inside the analysis output directory:

```
ci-failure-analysis/{pr-NNN|ci-NNN}/report.md
```

Use the `create` tool to write the full report content to this path. The report lives alongside the downloaded failure logs, making it easy to cross-reference the analysis with the raw log files.

**Examples:**
- PR #51196 analysis → `ci-failure-analysis/pr-51196/report.md`
- Scheduled build #129315 → `ci-failure-analysis/ci-129315/report.md`

## Important Notes

- **vcpkg only supports `>=` version constraints** — there is no way to express `<=` or `<` constraints. Never suggest "add a version constraint to prevent upgrading to version X" as a fix; it is not possible. Instead, recommend updating the consuming port to be compatible with the new version, or patching the port.
- The vcpkg Azure DevOps project (`vcpkg/public`) is **publicly accessible** — no authentication token is required for artifact downloads or build/artifact API calls
- **`web_fetch` cannot download binary ZIP files** — use PowerShell `Invoke-WebRequest` for artifact downloads
- **`resource.type` is `"PipelineArtifact"`**, not `"Container"` — the Container listing API (`/_apis/resources/Containers/{id}`) does not work; use `downloadUrl` directly
- **The test results API (`/_apis/test/runs`) requires authentication** even for public projects — skip it; failure logs contain sufficient information
- **Many `*-err.log` files are 0 bytes** — CMake, ninja, and make typically write errors to stdout; always check `*-out.log` when `*-err.log` is empty
- If a build is still `inProgress`, only partial results will be available; note this in the report
- Failure log artifacts are only published when there are actual failures; a missing artifact for a triplet means that triplet passed
- **`FILE_CONFLICTS` failures are invisible in artifacts** — they only appear as `REGRESSION:` lines in the "Test Modified Ports" step log; always scan step logs (Step 2b) before concluding the artifact list is complete
- The `"format.diff"` artifact (if present) indicates formatting or version file issues, not port build failures — report these separately
- `"z azcopy logs"` artifacts are infrastructure logs; skip these unless diagnosing asset cache issues
- **Android artifact sizes (~115–123 MB) typically share root causes with Linux** — if Linux analysis reveals a systemic issue (e.g., compiler header change, Python version), assume Android is affected too without full re-analysis
- **Downloaded logs are kept for manual review** in `ci-failure-analysis/` (gitignored). ZIP files are removed after extraction to save space, but the extracted logs and report are preserved. If disk space is a concern, old analysis directories can be deleted manually.
- **Case-sensitive file paths**: Linux and Android file systems are case-sensitive; Windows and macOS are not. A portfile referencing `${SOURCE_PATH}/LICENSE` will succeed on Windows/macOS even if the upstream file is named `License` or `license`, but will fail with "No such file or directory" on Linux/Android. When a BUILD_FAILED occurs only on Linux/Android with a missing file error, always check for a case mismatch against the actual upstream filename.
- **Two baseline files**: vcpkg CI uses **two** baseline files — `scripts/ci.baseline.txt` (per-port failures) and `scripts/ci.feature.baseline.txt` (per-feature/triplet failures). Always check both when classifying failures. Jobs can fail with exit code 1 and **no REGRESSION lines** when a port unexpectedly passes but is still marked as `fail` in `ci.feature.baseline.txt`. The error pattern in the step log is: `"passed but was marked expected to fail"`.
- **Android NDK macro collisions**: The Android NDK defines POSIX signal-related names (`si_value`, `si_pid`, `si_uid`, etc.) as preprocessor macros in `<asm-generic/siginfo.h>`. These can collide with C++ parameter names or member names, causing cryptic syntax errors like `error: expected ')'`. This is Android-specific — Linux, Windows, and macOS don't define these as macros.
- **C++26/libc++ transitive include breakage**: When a library compiles with `-std=c++2c` (C++26) using Clang/libc++ (macOS, Android), previously-transitive standard library includes may no longer be available. A missing `#include <algorithm>` that worked in C++20 may fail in C++26. MSVC and GCC/libstdc++ are more permissive about transitive includes.
- **Feature test failure artifacts**: When the CI runs feature tests (testing specific feature combinations), failure log artifacts use suffixed names like `portname_cpp`, `portname_all_3` instead of the base port name. These directories may contain `issue_body.md` (with the build error) and `tested-spec.txt` (the feature combination tested) instead of traditional build log files. Read `issue_body.md` first for quick triage — it contains a human-readable summary of the failure including error output.
- **Version validation failures**: The "Validate version files" task can fail *before any ports are tested* if the PR updated `vcpkg.json` but didn't run `vcpkg x-add-version`. This produces errors like `portname@N was not found in versions database` and `baseline.json: error: portname is assigned M, but the local port is N`. No failure log artifacts are produced. The fix is always `vcpkg x-add-version {portname}`.
- **Missing build tools (Go, Java, Rust)**: Some port features require external tools not installed on CI agents. Go is not available on macOS/Android agents ("Could not find GO_BIN") and has permission issues on Linux ("mkdir /go: permission denied"). When core port builds pass but specific features fail across all non-Windows triplets with tool-not-found errors, mark them as `feature-fails` in `ci.feature.baseline.txt`.
- **Feature baseline coverage gaps**: When `ci.feature.baseline.txt` entries only cover a subset of triplets (e.g., only `arm64-linux`), the same features failing on other triplets (e.g., `x64-linux`, `arm64-osx`, Android) will cause unexpected job failures with no REGRESSION lines. Always check whether baseline entries cover *all* affected triplets, not just one.
- **Portfile anti-patterns — do NOT recommend these as fixes:**
  - `set(VCPKG_BUILD_TYPE release)` — this is **only** appropriate for header-only libraries. Ports that produce binary output (`.lib`, `.a`, `.dll`, `.so`) must build both debug and release configurations. Never suggest adding this to fix mismatched-binary warnings.
  - `set(VCPKG_POLICY_* enabled)` — policy overrides are escape hatches for exceptional cases, not standard practice. Most ports should not set any `VCPKG_POLICY_*` variable. When a post-build check fails, the correct fix is almost always to fix the underlying issue (e.g., correct `vcpkg_cmake_config_fixup()` arguments, install missing files), not to suppress the warning with a policy override.
