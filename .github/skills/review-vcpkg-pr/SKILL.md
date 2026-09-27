---
name: review-vcpkg-pr
description: Review a microsoft/vcpkg pull request end-to-end.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | Pull request number to review. Substituted for `{{PR_NUMBER}}` throughout this skill and the shared guide. |
| `investigation-root` | No | Directory for workspaces and intermediate artifacts: sources, builds, installs, logs, and examples. If omitted, infer a short same-drive path when clear; otherwise ask. Never use the Copilot session directory or an arbitrary long temp path. |
| `review-depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Example invocations

- `/review-vcpkg-pr 12345`
- `/review-vcpkg-pr 12345 investigation-root D:/vcpkg-prs`

## Review requirements

Before changing directories, resolve `investigation-root` and `reviews/pr-{{PR_NUMBER}}` against the caller's original directory to absolute paths. Use the resolved report directory as `{{REPORT_DIR}}` throughout this skill and the shared guide; never rebase it onto the review workspace.

Before leaving the caller's directory, read all of `.github/skills/shared/review-vcpkg-pr-guide.md`; every instruction in it is mandatory.

Review the PR in a detached worktree or equivalent detached-HEAD workspace. Copy the caller's `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into its root. Do **not** switch branches or run mutable review steps in the caller's working tree.

If `VCPKG_DOWNLOADS` is already nonempty, preserve it for all review commands and subagents. Use that shared directory only through vcpkg; never clean or delete it. Otherwise, do not set it.

## Required outputs

Write only final deliverables in `{{REPORT_DIR}}`, not under `investigation-root`. The shared guide defines their contents:

1. `report.md`, including the guide's self-contained `## Fix handoff` for use without this session's chat history.
2. `patches/*.patch` -- only for `examples-and-patches`; omit if no patches were produced and explain any unpatched issues in the report.

Do not stop until `report.md` exists in `{{REPORT_DIR}}` and is complete.
