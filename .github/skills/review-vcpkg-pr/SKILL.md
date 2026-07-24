---
name: review-vcpkg-pr
description: Review a microsoft/vcpkg pull request end-to-end.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | Pull request number to review. Substituted for `{{PR_NUMBER}}` throughout this skill and the shared guide. |
| `investigation-root` | No | Preferred directory for large temporary work such as detached worktrees, extracted archives, build trees, example builds, installs, caches, and other investigation artifacts. Final review deliverables are not investigation artifacts and must still be written under `reviews/` in the caller's current directory. When omitted, infer a short same-drive investigations location if that is clear; otherwise ask the user. Do not use the Copilot session directory or an arbitrary long temp path. |
| `review-depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Example invocations

- `/review-vcpkg-pr 12345`
- `/review-vcpkg-pr 12345 investigation-root D:/vcpkg-prs`

## Review requirements

Check out the PR in a detached worktree or equivalent detached-HEAD workspace, and copy vcpkg.exe (Windows) or vcpkg (non-Windows) into it. For example, after `git worktree add D:\vcpkg2 origin/master`, copy `.\vcpkg.exe` to `D:\vcpkg2`. Do **not** switch branches or run mutable review steps in the caller's current working tree. Then apply the review process as described in .github/skills/shared/review-vcpkg-pr-guide.md.

Be sure to read all of .github/skills/shared/review-vcpkg-pr-guide.md

## Required outputs

Write all final deliverables under `reviews/pr-{{PR_NUMBER}}` in the caller's current directory, not under `investigation-root`. Find out what these mean from review-vcpkg-pr-guide.md.

1. `reviews/pr-{{PR_NUMBER}}/report.md`
2. `reviews/pr-{{PR_NUMBER}}/patches/*.patch` — only expected if review-depth is `examples-and-patches` and patches were produced

Do not stop until `reviews/pr-{{PR_NUMBER}}/report.md` exists and is complete.
