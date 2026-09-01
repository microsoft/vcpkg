---
name: analyze-ci-failures
metadata:
   version: 2026-08-14
description: >
  Analyze collected vcpkg CI failure evidence, classify regressions and known failures, identify root
  causes, recommend actions, and generate a report by package and triplet.

  USE FOR: explicit requests for CI regression triage, a failure inventory, baseline classification,
  action recommendations, or a formal CI failure report.

  DO NOT USE FOR: fetching logs as the final output, targeted debugging of one failure, answering a one-off
  question about logs the user pasted or pointed at, general coding, creating ports, or modifying portfiles.
  When requested analysis lacks local evidence, run fetch-vcpkg-ci-logs as the acquisition stage first.

  **ANALYSIS SKILL** USES: locally collected CI logs, vcpkg baselines, Azure DevOps metadata.
---

# vcpkg CI Failures Analyzer

## Overview

Consumes already-collected CI evidence, cross-references it with baselines, and produces a regression
report. If evidence has not yet been collected, invoke `fetch-vcpkg-ci-logs` first, then return to this
workflow. Do not duplicate its acquisition steps here.

## MCP Tools

| Tool | Purpose |
|------|---------|
| `github-mcp-server-get_file_contents` | Read baseline files |

## Prerequisites

- Local failed step logs and relevant extracted failure-log artifacts.
- Build metadata and full Azure build URL.
- For PR builds, PR metadata and full PR URL.

## Evidence Acquisition

When the required evidence is not already local, delegate acquisition to a subagent using
`fetch-vcpkg-ci-logs`. Prefer a fast, low-cost model for this mechanical work. Ask
the subagent to return only the evidence inventory and local paths; keep regression analysis and report
generation in the main agent.

When the evidence is already available locally, proceed directly to analysis.

## Workflow

> **OUTPUT RULE**: This skill applies only when the user asked for triage or report output, so a `report.md`
> is always required once it is selected. Write it as soon as step-log analysis completes, then enhance it
> from artifacts. Your response MUST also contain the complete report content — not a summary.

> **URL RULE**: Your response text (not just the report file) MUST include:
> - For scheduled/manual builds: the full Azure DevOps URL `https://dev.azure.com/vcpkg/public/_build/results?buildId={buildId}`
> - For PR builds: both the full PR URL `https://github.com/microsoft/vcpkg/pull/{prNumber}` AND the Azure DevOps build URL

Before analysis, read `.\.github\skills\shared\azure-vcpkg-ci-notes.md`.

### Phase 1: Analyze failed step logs

1. **Inventory evidence** — Confirm the build metadata, failed step-log paths, artifact paths, and triplets
   available from the acquisition step.
2. **Scan step logs** — Extract every `REGRESSION:` line and retain exact failure type keywords:
   `BUILD_FAILED`, `FILE_CONFLICTS`, `POST_BUILD_CHECKS_FAILED`, and
   `CASCADED_DUE_TO_MISSING_DEPENDENCIES`. Capture 2-3 surrounding lines for context.
3. **PR feature-test logs** — PR builds may not have `REGRESSION:` lines. Instead scan for `FAIL:`,
   `failed with`, and feature-test `error:` lines. Capture verbatim:
   - Compiler errors (missing headers, undefined symbols)
   - Post-build check failures (file path issues, misplaced files)
   - Version validation errors
   - Platform-specific feature guard messages
   
   Report each feature failure individually. Dependency ports that fail get their own entry.
4. **Version validation** — Inspect the `"Validate version files"` evidence for version database errors.
5. **Write report immediately** — Generate and save `report.md` using the step-log evidence.

### Phase 2: Analyze artifacts and enhance

6. **Analyze artifacts** — Read relevant `stdout-{triplet}.log` tails and supporting logs. Classify per
   [references/vcpkg-failure-patterns.md](references/vcpkg-failure-patterns.md).
7. **Baselines** — Check both `ci.baseline.txt` and `ci.feature.baseline.txt`.
8. **Enhance report** — Add root causes, downstream impact, and actionable recommendations supported by
   the evidence.

### Report Requirements

Format per [references/report-template.md](references/report-template.md):
- Full build URL: `[{buildNumber}](https://dev.azure.com/vcpkg/public/_build/results?buildId={buildId})`
- For PRs: `[#{prNumber}](https://github.com/microsoft/vcpkg/pull/{prNumber})`
- List **every** triplet by full name (e.g., `x64-windows`, `arm64-linux`) — never "N triplets". Only include triplets that actually had failures for this specific build.
- Use **exact** failure type keywords from logs: `BUILD_FAILED`, `POST_BUILD_CHECKS_FAILED`, `FILE_CONFLICTS`, `CASCADED_DUE_TO_MISSING_DEPENDENCIES` — never paraphrase
- Include error messages verbatim — quote the exact text from logs for compiler errors, path issues, and validation failures
- Dependency ports' failures as separate entries
- **Include baseline/known failures** — report them with their failure types, but classify them separately from new regressions

## Output Structure

Write reports under the session folder from the environment context, alongside the raw evidence, never
into the repository working tree:

```text
{session-folder}/files/ci-failure-analysis/
├── ci-129315/         ← scheduled build
│   └── report.md
└── pr-51202/          ← PR build
    └── report.md
```

Raw evidence stays where `fetch-vcpkg-ci-logs` placed it, in
`{session-folder}/files/ci-failure-logs/`; reference those paths from the report instead of copying them.

## Critical Rules

- Do not fetch or download logs as part of this skill; use the acquisition skill first.
- Scan step logs first because `FILE_CONFLICTS` may appear only there.
- Check **both** baseline files
- Never suggest `<=` version constraints or `VCPKG_BUILD_TYPE release`
- Clearly distinguish proven root causes from hypotheses and requests for additional diagnostics.
