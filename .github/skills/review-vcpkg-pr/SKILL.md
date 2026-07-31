---
name: review-vcpkg-pr
description: Review a microsoft/vcpkg pull request end-to-end.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | Pull request number to review. Substituted for `{{PR_NUMBER}}` throughout this skill and the shared guide. |
| `investigation-root` | No | Directory for large temporary artifacts such as worktrees, sources, builds, examples, and installs. Final deliverables still go under `reviews/` in the caller's current directory. If omitted, infer a short same-drive path when clear; otherwise ask. Never use the Copilot session directory or an arbitrary long temp path. |
| `review-depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Example invocations

- `/review-vcpkg-pr 12345`
- `/review-vcpkg-pr 12345 investigation-root D:/vcpkg-prs`

## Review requirements

Read all of `.github/skills/shared/review-vcpkg-pr-guide.md` before reviewing; every instruction in it is mandatory.

Review the PR in a detached worktree or equivalent detached-HEAD workspace, with `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) copied into it. For example, after `git worktree add D:\vcpkg2 origin/master`, copy `.\vcpkg.exe` to `D:\vcpkg2`. Do **not** switch branches or run mutable review steps in the caller's current working tree.

## Required outputs

Write all final deliverables under `reviews/pr-{{PR_NUMBER}}` in the caller's current directory, not under `investigation-root`. The shared guide defines their contents.

1. `reviews/pr-{{PR_NUMBER}}/report.md`
2. `reviews/pr-{{PR_NUMBER}}/patches/*.patch` — only expected if review-depth is `examples-and-patches` and patches were produced

Do not stop until `reviews/pr-{{PR_NUMBER}}/report.md` exists and is complete.
