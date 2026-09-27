---
name: evaluate-new-port
description: 'Audit a vcpkg port locally. Reads the port metadata and build recipe, installs the port, inspects extracted sources and installed files, and produces a report covering license risks, vendored code, optional dependencies, and other port review suggestions.'
argument-hint: 'Port name (e.g. "libpng")'
---

# Evaluate New Port

## When to Use

- Reviewing a newly added or substantially updated port
- Auditing whether a port's declared license metadata matches what it installs
- Checking for vendored third-party code or optional dependencies that are not modeled in `vcpkg.json`
- Looking for packaging or review issues after a real local install

## Overview

This skill takes a single port name, reads the port's metadata and build recipe, performs a clean local install, and writes a structured audit report. The audit focuses on:

- **Declared license metadata** from `ports/{port-name}/vcpkg.json`, including feature-scoped declarations
- **Build invocation** and feature toggles from `ports/{port-name}/portfile.cmake`
- **Real build output** after `vcpkg x-ci-clean` and `vcpkg install {port-name}`
- **Extracted source tree** under `buildtrees/{port-name}/src`
- **Installed package contents** under `packages/{port-name}_{target-triplet}`
- **Code review suggestions** for the port's packaging logic and metadata

If the install reports that the port is unsupported on the current platform or triplet, stop there and recommend a more appropriate platform instead of continuing the audit.

## Required Inputs

- A valid port name present under `ports/{port-name}`

## Detailed Workflow

### Step 1: Read the Port Metadata

Open these files first:

- `ports/{port-name}/vcpkg.json`
- `ports/{port-name}/portfile.cmake`

Extract at least the following:

**From `vcpkg.json`:**
- top-level `license`, if present
- any feature-scoped `license` declarations, including explicit `null`
- `homepage`
- `features`
- `dependencies`
- `supports`, if present

**From `portfile.cmake`:**
- The primary build helper used (`vcpkg_cmake_configure`, `vcpkg_configure_make`, `vcpkg_cmake_build`, Meson helpers, raw `cmake`, etc.)
- Feature-to-build-option mappings
- Explicit enable/disable flags for optional upstream components
- Any platform guards, fatal errors, or unsupported conditions
- Any bundling, patching, or file-pruning logic relevant to installed content

### Step 2: Clean the Local Working State

Run the repository-local vcpkg executable from the repository root:

**Windows:**
```powershell
.\vcpkg.exe x-ci-clean
```

**Linux/macOS:**
```bash
./vcpkg x-ci-clean
```

Do not skip this step. The audit should be based on a fresh source extraction and package install.

### Step 3: Install the Port

Run a normal install of the requested port:

**Windows:**
```powershell
.\vcpkg.exe install {port-name}
```

**Linux/macOS:**
```bash
./vcpkg install {port-name}
```

Capture the output. If it contains an unsupported-platform message, stop the workflow and report:

1. That the current platform cannot evaluate this port meaningfully
2. The reason quoted from the install output or `portfile.cmake`
3. A suggested alternate platform, chosen from evidence in `supports`, platform guards, or fatal-error text

Common examples:
- `only supports Windows` → suggest Windows
- `only supports Linux` → suggest Linux
- `only supports x64 and x86 Windows` → suggest an x64 Windows host
- `Building for {TARGET_TRIPLET} on {HOST_TRIPLET} is unsupported` → suggest the native target platform instead of cross-building

If the install succeeds, continue.

If the install hit a binary cache and you need to rerun the port to force a local rebuild for inspection, remove and reinstall the affected port directly rather than running `x-ci-clean` followed by `install --no-binarycaching`. That preserves cache hits for unedited dependencies while still rebuilding the port under review.

### Step 4: Determine the Installed Triplet Directory

Find the installed package directory under:

```text
packages/{port-name}_{target-triplet}
```

Use the package directory that was created by the install you just ran. The triplet is normally the system default target triplet (for example `x64-windows`, `arm64-windows`, or `x64-linux`).

If multiple matching directories exist, prefer the one whose timestamp matches the current install output. Record the chosen triplet in the report.

### Step 5: Audit the Extracted Source Tree

Inspect `buildtrees/{port-name}/src` and identify the extracted source directory or directories for the current build. Review them for vendoring and undeclared optional dependencies.

#### 5a. Vendored Dependencies

Look for signs of bundled third-party code, such as directories or files named:

- `third_party`
- `third-party`
- `vendor`
- `vendors`
- `extern`
- `external`
- `deps`
- `dependencies`
- `subprojects`
- nested copies of well-known libraries

For each candidate:
- identify the bundled project if possible
- determine whether it is built or installed
- check whether the same dependency is already modeled in `vcpkg.json`
- note whether the portfile patches it out, replaces it with a vcpkg dependency, or leaves it vendored

#### 5b. Optional Dependencies Not Explicitly Controlled

Look for optional integrations that are present upstream but not clearly controlled in packaging. Sources of evidence include:

- `find_package(...)`
- `pkg_check_modules(...)`
- `option(...)`
- `WITH_*`, `ENABLE_*`, `USE_*`, `BUILD_*`
- Meson `feature` or `dependency(...)`
- Autotools `--with-*` / `--enable-*`

Flag an issue when an optional dependency:

- appears in upstream build logic,
- is not declared in `vcpkg.json`, and
- is not explicitly enabled or disabled by `portfile.cmake`

The point is to find dependencies that may be auto-detected from the host environment, leading to non-reproducible builds.

### Step 6: Audit Installed Content Against the Declared License Metadata

Inspect the package contents under `packages/{port-name}_{target-triplet}`. Focus on:

- `share/{port-name}/copyright`
- installed license files
- headers, sources, examples, tools, or assets originating from bundled third-party code
- any embedded notices for code under additional licenses

Treat explicit `"license": null` as intentional metadata meaning "no SPDX expression is provided here; inspect the installed copyright file." Do not report that case as missing metadata by itself.

Flag content when:

- the installed files include third-party components under licenses not covered by the declared license metadata,
- multiple upstream licenses appear to require a more precise SPDX expression,
- or the package installs bundled code whose license is absent from the declared metadata and copyright file

Do not assume every extra notice is a bug. Record the evidence and explain whether it appears compatible, incomplete, or suspicious.

### Step 7: Review the Portfile for Packaging Suggestions

While auditing `ports/{port-name}/portfile.cmake`, look for common review items such as:

- missing explicit disable flags for tests, docs, examples, benchmarks, or tools
- optional dependencies that should be feature-gated
- vendored libraries that could be replaced with vcpkg dependencies
- install steps that might ship unnecessary files
- missing cleanup of debug-only or duplicate artifacts
- support restrictions that should move into `supports` in `vcpkg.json`
- license metadata that is too broad or incomplete after considering top-level and feature-scoped declarations

Only report suggestions supported by evidence from the files or the install result.

## Output Requirements

Generate a markdown report with these sections:

1. **Port Summary**
2. **Declared Metadata**
3. **Build Invocation Summary**
4. **Install Result**
5. **Vendored Dependencies**
6. **Optional Dependency Risks**
7. **License / Installed Content Findings**
8. **Other Port Review Suggestions**
9. **Recommended Follow-ups**

Be specific. Cite file paths and brief snippets when they support a finding.

If there are no findings for a section, write `None found` instead of omitting the section.

## Suggested Report Template

See `references/report-template.md`.

## Execution Notes

- Run from the repository root
- Prefer repository-local paths in all findings
- Do not continue source/package inspection after an unsupported install result
- Base conclusions on the actual installed package directory created by this run
- Keep the final report focused on actionable review feedback rather than restating raw command output
