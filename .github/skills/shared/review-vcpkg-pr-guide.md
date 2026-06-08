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

## Workspace and branch safety

1. Do **not** change branches in the calling repository or otherwise repurpose the caller's current working tree during the review. Treat that repository state as an anchor for inputs and final deliverables, not as the mutable investigation checkout.
2. Perform PR checkouts, builds, edits, patch generation, and other mutable investigation steps inside isolated investigation workspaces.
3. Prefer detached investigation checkouts such as `git worktree add --detach <path> <start-point>` or an equivalent detached-HEAD workflow. Avoid attaching investigation state to the caller's active branch.
4. Prefer investigation workspaces on the same drive as the initial repository and choose short paths to reduce Windows path-length risk.
5. Avoid placing worktrees or other heavy investigation directories under Copilot session-state directories when a suitable same-drive location is available.
6. If the appropriate investigations directory is not clear from the user's request or obvious repository-local conventions, ask the user before creating the workspaces.

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
- Unusual Aspects and Prior Art

Add any other sections needed to make the review clear and evidence-based.

The "Paste-ready review comment" section should be short enough to paste into a PR review comment with little or no editing. Attribute the note to the language model used for the review, for example `AI review note (GPT-5.4): ...` or equivalent wording that clearly signals the comment came from the model rather than a human maintainer.

## Pre-existing issues vs. regressions

Distinguish carefully between defects introduced by the PR and defects that were already present in the previous packaged version.

- For a simple version bump or similarly narrow update, pre-existing package issues are usually not blocking on their own.
- In those cases, prefer a conclusion such as **approve with notes**, use the machine-readable `verdict` value `approve-with-notes`, and describe the known issues as pre-existing in the report.
- Only use `request-changes` for issues that are regressions, issues directly caused by the PR, or pre-existing issues that the PR changes in a way that makes the package materially less safe or less consumable than before.
- If you mention a pre-existing issue in a version-bump review, say explicitly that it predates the PR and is being called out for maintainer awareness rather than as a merge blocker.

## Critical rules

- Prefer concrete evidence over conjecture.
- Read both the PR diff and the conversation history.
- Files in the port directory should use LF line endings.
- Keep any patches focused and directly applicable by maintainers.
- Avoid unrelated churn in example code and candidate fixes.
- If no safe patch is warranted, explain why rather than forcing one.
