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

Work autonomously. Use web and repository tooling as needed. Prefer concrete evidence and cite relevant files, checklist items, commands, and build or integration results in the report.

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
  "verdict": "approve | request-changes | unknown",
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

Use exactly one of these verdict values: `approve`, `request-changes`, or `unknown`.

If patches are out of scope for the wrapper skill, leave `patches` empty and set each issue's `patch` field to `null`.

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
- Scope reviewed
- Findings
- New Port
  - Provenance
  - Naming
  - Maturity
  - Optional Dependencies
- Unusual Aspects and Prior Art

Add any other sections needed to make the review clear and evidence-based.

## Critical rules

- Prefer concrete evidence over conjecture.
- Read both the PR diff and the conversation history.
- Files in the port directory should use LF line endings.
- Keep any patches focused and directly applicable by maintainers.
- Avoid unrelated churn in example code and candidate fixes.
- If no safe patch is warranted, explain why rather than forcing one.
