# Shared vcpkg PR Review Guide

Read this file before performing either a single-PR review or a batch PR triage.

## Core review standard

Review vcpkg PRs according to:

- <https://learn.microsoft.com/en-us/vcpkg/contributing/maintainer-guide>
- <https://learn.microsoft.com/en-us/vcpkg/contributing/pr-review-checklist>

Always read the PR description and the full conversation history before concluding.

## Shared review scope

For each PR under review:

1. Review the PR against the maintainer guide and PR review checklist.
2. Review the upstream source for optional dependencies and verify the portfile controls them correctly.
3. Research the library's provenance and naming:
   - whether the repository or project is the primary association for the name
   - whether the package name could confuse users in a package manager
4. Highlight unusual aspects of the portfile and find similar prior art in other vcpkg ports.
5. If the PR adds one or more new ports, run the `evaluate-new-port` skill for each newly added port from the PR checkout and incorporate those audit results into the PR review instead of treating them as a separate standalone deliverable.

Work autonomously. Use web and repository tooling as needed. Prefer concrete evidence and cite relevant files, checklist items, commands, and build or integration results in the report.

## Workspace and branch safety

1. Do **not** change branches in the calling repository or otherwise repurpose the caller's current working tree during the review. Treat that repository state as an anchor for inputs and final deliverables, not as the mutable investigation checkout.
2. Perform PR checkouts, builds, edits, patch generation, and other mutable investigation steps inside isolated investigation workspaces.
3. Prefer detached investigation checkouts such as `git worktree add --detach <path> <start-point>` or an equivalent detached-HEAD workflow. Avoid attaching investigation state to the caller's active branch.
4. Prefer investigation workspaces on the same drive as the initial repository and choose short paths to reduce Windows path-length risk.
5. Avoid placing worktrees or other heavy investigation directories under Copilot session-state directories when a suitable same-drive location is available.
6. If the appropriate investigations directory is not clear from the user's request or obvious repository-local conventions, ask the user before creating the workspaces.
7. On Windows, after creating a worktree, copy the repository-local `vcpkg.exe` from the starting repository into that worktree instead of rerunning bootstrap. For example, after `git worktree add D:\vcpkg2 origin/master`, copy `.\vcpkg.exe` to `D:\vcpkg2`.

## Standard deliverables per PR

Unless the wrapper skill narrows the scope, write these files for each reviewed PR:

1. `report.md` — a human-readable review
2. `results.json` — structured machine-readable results

If the wrapper skill permits patches, place them under `patches\`.

## Standard results format

Use this schema for `results.json`:

```json
{
  "schemaVersion": 1,
  "pr": 12345,
  "status": "completed",
  "verdict": "approve | approve-with-notes | request-changes | unknown",
  "summary": "one or two sentence summary",
  "issues": [
    {
      "id": "short-stable-id",
      "title": "issue title",
      "severity": "blocking | non-blocking | informational",
      "details": "concise evidence-backed detail",
      "patch": "patches/0001-focused-fix.patch or null",
      "validation": "commands or checks run"
    }
  ],
  "newPortEvaluations": [
    {
      "port": "port-name",
      "status": "completed | unsupported | failed",
      "summary": "one or two sentence audit summary",
      "report": "path to any saved supporting audit notes or null"
    }
  ],
  "patches": [
    {
      "path": "patches/0001-focused-fix.patch",
      "description": "what the patch fixes",
      "issue": "short-stable-id",
      "validation": "git apply --check and any build/test command run"
    }
  ]
}
```

Use exactly one of these verdict values: `approve`, `approve-with-notes`, `request-changes`, or `unknown`.

Use `approve-with-notes` when the PR is acceptable to merge but you still want to call out non-blocking concerns, caveats, or pre-existing package problems. Keep those notes in the report text and model them in `issues` using `non-blocking` or `informational` severities as appropriate.

If patches are out of scope for the wrapper skill, leave `patches` empty and set each issue's `patch` field to `null`.

If the PR does not add a new port, set `newPortEvaluations` to an empty array. If it does add a new port, include one entry per evaluated new port and also flow any material findings into `summary`, `issues`, and the final verdict rather than isolating them in that array.

## Azure CI failure handling

When GitHub checks or PR comments mention failing vcpkg Azure CI, fetch the public build logs anonymously instead of stopping at the web UI.

First, read `.\.github\skills\shared\azure-vcpkg-ci-notes.md` and follow its Azure-specific rules.

Prefer the shared helper script:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
```

If a matrix check's `details_url` contains a job id and you need to narrow the scope, pass it explicitly:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr> -JobId <job-id>
```

## Standard report format

`report.md` should include these sections when they are applicable to the review depth selected by the wrapper skill:

- Brief Summary + Conclusion with `#{pr}` and `https://github.com/microsoft/vcpkg/pull/{pr}/files`
- Paste-ready review comment
- Scope reviewed
- Findings
- New Port
  - Provenance
  - Naming
  - Maturity
  - Optional Dependencies
  - `evaluate-new-port` Audit Summary
- Unusual Aspects and Prior Art

Add any other sections needed to make the review clear and evidence-based.

For the `New Port` subsection meanings:

- `Provenance` should explain where the source comes from and how confidently it maps to the packaged project.
- `Naming` should explain whether the chosen port name is clear and appropriate for package-manager users.
- `Maturity` should follow the maintainer-guide requirement that packaged projects should be mature. In practice, describe the upstream library's age, release history, maintenance signals, stability, and whether it appears established enough for broad package-manager distribution. Do **not** use `Maturity` to discuss whether the port installed locally, whether its CMake/package config works, or other packaging-surface details; those belong in `Findings` or the `evaluate-new-port` audit summary.
- `Optional Dependencies` should focus on upstream optional integrations and whether the port models them reproducibly.

The "Paste-ready review comment" section should be short enough to paste into a PR review comment with little or no editing. Attribute the note to the language model used for the review in the third person, for example `GPT-5.4 observes that ...`, but use the exact runtime model name for the current review rather than hardcoding or guessing another model. If you cannot determine the exact model name confidently from the current runtime context, do **not** invent one; fall back to a generic attribution such as `The review model observes that ...`. Focus on the substantive findings rather than repeating the overall review status.

State the current recommendation directly rather than as hypothetical reviewer intent. Do **not** write phrases such as `I would merge`, `I would approve`, or `I would request changes`; instead, say explicitly whether the cited issue is blocking or not blocking and why, so the pasted comment already reads like the final maintainer-facing note.

Do not spend the paste-ready comment on facts that are already obvious from the PR page or GitHub UI, such as the PR title, author, open state, or that checks are green. Mention Azure or GitHub check status there only when it is necessary to explain why a finding is or is not blocking, or why the visible signal cannot be trusted.

When a PR adds multiple new ports, give each port its own subsection under "New Port" and summarize the corresponding `evaluate-new-port` findings there.

## Pre-existing issues vs. regressions

Distinguish carefully between defects introduced by the PR and defects that were already present in the previous packaged version.

- For a simple version bump or similarly narrow update, pre-existing package issues are usually not blocking on their own.
- In those cases, prefer a conclusion such as **approve with notes**, use the machine-readable `verdict` value `approve-with-notes`, and describe the known issues as pre-existing in the report.
- Only use `request-changes` for issues that are regressions, issues directly caused by the PR, or pre-existing issues that the PR changes in a way that makes the package materially less safe or less consumable than before.
- If you mention a pre-existing issue in a version-bump review, say explicitly that it predates the PR and is being called out for maintainer awareness rather than as a merge blocker.
- Port-side "breaking changes" such as feature renames or reshaping usage metadata are not automatically blocking if the relevant downstreams in the vcpkg registry still build successfully in CI. Treat them as blocking only when you have evidence of an actual downstream or consumer regression, or when the CI signal is invalidated for another reason.
- If a PR claims to change which sources are fetched or patches applied, verify that the corresponding `SHA512` was updated correctly. A stale `SHA512` can hit the asset cache and supply old content, which can make the build lab test the wrong sources.

## Critical rules

- Prefer concrete evidence over conjecture.
- Read both the PR diff and the conversation history.
- Check the usage text generated by `vcpkg install`; it is both evidence for consumer guidance and a useful hint for which example applications are meaningful to build.
- Missing CMake or pkg-config bindings are not noteworthy on their own unless the upstream sources suggest those bindings are intended to exist. In particular, header-only libraries often only support direct include/MSBuild-style consumption.
- Do not treat the mere absence of published downstream C++ standard metadata as a blocking issue on its own. In this ecosystem, many ports require a newer C++ standard without explicitly communicating that requirement through installed metadata, and that alone should normally still land as `approve` rather than `approve-with-notes` or `request-changes`.
- Do report contradictory published C++ standard requirements as a real bug. For example, if the built package actually requires C++20 but the installed metadata explicitly advertises `cxx_std_17` or an equivalent lower requirement, that contradiction is consumer-visible and should be called out.
- When reviewing license metadata, inspect the full `vcpkg.json` structure rather than only the top-level `license` field. Feature-scoped `license` entries and explicit `"license": null` are still meaningful declarations: `null` means the manifest does not provide an SPDX expression and the reviewer should read the installed copyright file rather than treating the metadata as simply missing.
- When reviewing installed CMake package files for consumer-side dependency handling, inspect the actual generated `*Config.cmake` or `*-config.cmake` that consumers load and read enough surrounding control flow to determine whether the behavior is reachable.
- Do not flag dead branches as consumer issues. A fallback guarded by a literal-disabled condition such as `if(FALSE)` or an equivalent statically unreachable branch is not evidence of an active download path on its own.
- Changes in shared build helpers or `scripts/cmake` that affect many ports need explicit justification for why a global change is necessary to fix the PR's problem unless that scope is already obvious from the diff and problem statement.
- In portfiles, prefer `vcpkg_check_linkage(...)` over mutating `VCPKG_LIBRARY_LINKAGE` directly. Flag `set(VCPKG_LIBRARY_LINKAGE ...)` in a port as review feedback unless the change is defining a triplet rather than port behavior.
- Functions in `scripts/cmake` that already have helper-port replacements must not be edited as part of a port review. Reviewers should treat these legacy shared helpers as frozen and direct the consumer port to adopt the helper-port version instead.
  - `vcpkg_configure_cmake()`, `vcpkg_build_cmake()`, and `vcpkg_install_cmake()` -> `vcpkg-cmake` via `vcpkg_cmake_configure()`, `vcpkg_cmake_build()`, and `vcpkg_cmake_install()`
  - `vcpkg_fixup_cmake_targets()` -> `vcpkg-cmake-config` via `vcpkg_cmake_config_fixup()`
  - `vcpkg_configure_make()`, `vcpkg_build_make()`, and `vcpkg_install_make()` -> `vcpkg-make` via `vcpkg_make_configure()` and `vcpkg_make_install()`
  - `vcpkg_configure_qmake()`, `vcpkg_build_qmake()`, and `vcpkg_install_qmake()` -> `vcpkg-qmake` via `vcpkg_qmake_configure()`, `vcpkg_qmake_build()`, and `vcpkg_qmake_install()`
  - `vcpkg_build_msbuild()` and `vcpkg_install_msbuild()` -> `vcpkg-msbuild` via `vcpkg_msbuild_install()`
  - `vcpkg_configure_meson()` and `vcpkg_install_meson()` -> `vcpkg-tool-meson` via the helper-port versions of `vcpkg_configure_meson()` and `vcpkg_install_meson()`
  - `z_vcpkg_get_cmake_vars()` -> `vcpkg-cmake-get-vars` via `vcpkg_cmake_get_vars()`
  - For future additions, look for helper ports that `set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)`.
- Files in the port directory should use LF line endings.
- Keep any patches focused and directly applicable by maintainers.
- Avoid unrelated churn in example code and candidate fixes.
- If no safe patch is warranted, explain why rather than forcing one.
