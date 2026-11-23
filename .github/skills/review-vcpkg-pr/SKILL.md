---
name: review-vcpkg-pr
description: Review a microsoft/vcpkg pull request end-to-end.
disable-model-invocation: true
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | Pull request number to review. Substituted for `{{PR_NUMBER}}` throughout this skill and the shared guide. |
| `investigation-root` | No | Directory for PR worktrees and intermediate artifacts: sources, builds, installs, logs, and examples. Defaults to `.worktrees` in the main worktree, which is the first `worktree` path printed by `git worktree list --porcelain` in the caller's directory. Never use the Copilot session directory or an arbitrary long temp path. |

### Example invocations

- `/review-vcpkg-pr 12345`
- `/review-vcpkg-pr 12345 investigation-root D:/vcpkg-prs`

## Review requirements

Before changing directories, resolve `investigation-root` and `reviews/pr-{{PR_NUMBER}}` against the caller's original directory to absolute paths. Use the resolved report directory as `{{REPORT_DIR}}` throughout this skill and the shared guide; never rebase it onto the review workspace.

Before leaving the caller's directory, read all of `.github/skills/shared/review-vcpkg-pr-guide.md`; every instruction in it is mandatory.

Create `<investigation-root>/pr-{{PR_NUMBER}}` at the PR head with `git worktree add --detach` from the caller's repository, and review the PR there. It must be a linked worktree, not a clone or copy. Invoking this skill explicitly requests this worktree. If it already exists, detach it at the PR head instead; preserve its branches and commits, and ask before discarding uncommitted changes whose origin is unclear. Keep other intermediate artifacts in `<investigation-root>/pr-{{PR_NUMBER}}-artifacts`. Copy the caller's `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into the worktree root. Do **not** switch branches or run mutable review steps in the caller's working tree.

If `VCPKG_DOWNLOADS` is already nonempty, preserve it for all review commands and subagents. Use that shared directory only through vcpkg; never clean or delete it. Otherwise, do not set it.

## Required outputs

Write only final deliverables in `{{REPORT_DIR}}`, not under `investigation-root`. The shared guide defines their contents:

1. `report.md`, including the guide's self-contained `## Fix handoff` for use without this session's chat history.

Do not stop until `report.md` exists in `{{REPORT_DIR}}` and is complete.
