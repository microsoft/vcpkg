---
name: analyze-ci-failures
description: >
  Analyze vcpkg Azure DevOps CI failures. Downloads logs, identifies regression root causes,
  generates a report by package and triplet.

  USE FOR: CI failure analysis, regression triage, log diagnosis.

  DO NOT USE FOR: general coding, creating ports, modifying portfiles.

  **UTILITY SKILL** INVOKES: Azure DevOps REST API, PowerShell.
---

# vcpkg CI Failures Analyzer

## When to Use

- Investigating CI failures on Azure DevOps
- Identifying regressions in a PR or scheduled build
- Triaging root causes before assigning bugs

## Overview

Fetches build metadata and failure logs via Azure DevOps REST API, cross-references with baselines, produces a regression report.

## MCP Tools

| Tool | Purpose |
|------|---------|
| `github-mcp-server-get_file_contents` | Read baseline files |

## Prerequisites

- **GitHub MCP server** — needed for PR URL input

## Workflow

> **OUTPUT RULE**: Write `report.md` as SOON as step-log analysis (Phase 1) completes. Do not wait for artifact downloads. You can update the file later. Your response MUST also contain the complete report content — not a summary.

### Phase 1: Extract failures from step logs (REQUIRED — do first)

1. **Parse input** — Extract `buildId` from Azure DevOps URL. For PR URLs:
   ```powershell
   $prNumber = 51515
   $builds = (Invoke-RestMethod "https://dev.azure.com/vcpkg/public/_apis/build/builds?reasonFilter=pullRequest&repositoryType=GitHub&repositoryId=microsoft/vcpkg&branchName=refs/pull/$prNumber/merge&api-version=7.0").value
   $buildId = ($builds | Sort-Object -Property id -Descending | Select-Object -First 1).id
   ```
   See [references/azure-devops-api.md](references/azure-devops-api.md).
2. **Fetch metadata** — Build info, timeline, and artifacts list (parallelize these API calls).
3. **Scan step logs** — For each failed job, find `"*** Test Modified Ports"` task and fetch its log:
   ```powershell
   $logText = Invoke-RestMethod "$($task.log.url)?api-version=7.0"
   $regressions = $logText -split "`n" | Where-Object { $_ -match 'REGRESSION:' }
   ```
   Captures all types: `BUILD_FAILED`, `FILE_CONFLICTS`, `POST_BUILD_CHECKS_FAILED`, `is marked as fail but dependency not supported`. **Report every REGRESSION line.** Also capture 2-3 lines around each error for root cause context.
4. **PR feature-test logs** — PR builds may NOT have `REGRESSION:` lines. Instead scan for `FAIL:` or `failed with` lines showing per-feature failures. Report each feature failure individually. Dependency ports that fail get their own entry.
5. **Version validation** — Check `"Validate version files"` task. If failed, scan for `"was not found in versions database"`. Fix: `vcpkg x-add-version`.
6. **Write report immediately** — Generate and save `report.md` using all step-log data. This ensures output exists even if later steps time out.

### Phase 2: Download logs and enhance (time permitting)

7. **Download logs** — `Invoke-WebRequest` for artifact ZIPs (not `web_fetch`). Only download `"failure logs for {triplet}"` — skip `"file lists"`, `"z azcopy logs"`. Extract into `ci-failure-analysis/{scope}/logs/{triplet}/`. If download fails, still create the directory with a placeholder noting the URL.
8. **Analyze** — Read `stdout-{triplet}.log` last lines. Classify per [references/vcpkg-failure-patterns.md](references/vcpkg-failure-patterns.md). Update report with additional root cause detail.
9. **Baselines** — Check both `ci.baseline.txt` and `ci.feature.baseline.txt`.

### Report Requirements

Format per [references/report-template.md](references/report-template.md):
- Full build URL: `[{buildNumber}](https://dev.azure.com/vcpkg/public/_build/results?buildId={buildId})`
- For PRs: `[#{prNumber}](https://github.com/microsoft/vcpkg/pull/{prNumber})`
- List **every** triplet by full name — never "N triplets"
- Use **exact** failure type keywords, not paraphrases
- Include error messages verbatim (e.g. `unistd.h`, `${CURRENT_PACKAGES_DIR}/debug/include`)
- Dependency ports' failures as separate entries

## Output Structure

```
ci-failure-analysis/
├── ci-129315/         ← scheduled build
│   ├── report.md
│   └── logs/
│       ├── x64-windows/
│       └── arm64-linux/
└── pr-51202/          ← PR build
    ├── report.md
    └── logs/
```

## Critical Rules

- Use `Invoke-WebRequest` for ZIPs — `web_fetch` can't download binaries
- Artifact type is `PipelineArtifact` — Container API won't work
- Scan step logs first — `FILE_CONFLICTS` only appear there
- Check **both** baseline files
- Never suggest `<=` version constraints or `VCPKG_BUILD_TYPE release`
- If artifact download fails, still create `logs/{triplet}/` directory with a placeholder noting the download URL
