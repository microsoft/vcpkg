---
name: review-vcpkg-pr
description: Review a microsoft/vcpkg pull request end-to-end. Use when asked to perform a maintainer-style PR review with a report, results.json, optional focused patches, and Azure CI log investigation.
---

# vcpkg PR Reviewer

First, read `.\.github\skills\shared\review-vcpkg-pr-guide.md` and follow it as the shared contract for the review.

## Inputs

Parse these from the user's request.

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | Pull request number to review. |
| `report root` | No | Directory for final deliverables. Default to `reviews` under the current working directory. |
| `investigation root` | No | Preferred directory for large temporary work such as detached worktrees, extracted archives, build trees, example builds, installs, caches, and other investigation artifacts. When omitted, infer a short same-drive investigations location if that is clear; otherwise ask the user. |

### Input handling rules

1. If `report root` is omitted, resolve it to `.\reviews` from the current working directory.
2. If `investigation root` is provided, strongly prefer it for heavy temporary work and keep the final deliverables under `report root`.
3. If `investigation root` is omitted, prefer a short investigations path on the same drive as the initial repository instead of the Copilot session directory or an arbitrary long temp path.
4. If no suitable investigations location is clear, ask the user before creating worktrees or other heavy investigation artifacts.
5. Check out the PR in a detached worktree or equivalent detached-HEAD workspace. Do **not** switch branches or run mutable review steps in the caller's current working tree.

### Example invocations

- `Use /review-vcpkg-pr for PR 12345.`
- `Use /review-vcpkg-pr for PR 12345 with report root C:\temp\reviews\pr-12345.`
- `Use /review-vcpkg-pr for PR 12345 with report root C:\temp\reviews\pr-12345 and investigation root D:\investigations\pr-12345.`

## Required outputs

Write all final deliverables under `report root`:

1. `report.md` — thorough human-readable review
2. `results.json` — structured machine-readable results
3. `patches\*.patch` — optional focused patches, one issue per patch

Do not stop until `report root\report.md` and `report root\results.json` exist and are complete.

## Single-PR deep review requirements

In addition to the shared guide:

1. Create an example application that demonstrates:
   - `find_package`
   - `pkg-config`
   - "MSBuild Style": include only `<triplet>\include` and link all `*.lib` files, with no extra macro defines. Any needed configuration should already be baked into the installed headers.
2. If you create an example app or other supporting files, keep them under `investigation root` when it is provided. Otherwise keep them under the inferred same-drive investigation workspace, and mention the paths in the report.
3. When you find an issue that a vcpkg maintainer could reasonably apply directly, prepare a focused validated patch for it. Create patches as real files under `report root\patches` using `git format-patch` from commits based on the PR head. Each patch must address one issue, avoid scope creep, avoid unrelated formatting churn, and be validated against the PR head with at least `git apply --check` plus targeted build and test commands when practical. Record that validation in `results.json`.
4. It is acceptable to leave the patch directory empty when no safe focused patch is warranted. Do not fabricate patches.
5. If the PR is a simple version bump and the only material problems you find were already present in the previous packaged version, do not block solely on that basis. Report those items as notes, use the separate `approve-with-notes` outcome when appropriate, and rely on the shared guide for the exact report, results, and paste-ready comment requirements.

## Shared helper

When Azure CI log investigation is needed, prefer:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
```
