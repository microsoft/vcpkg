---
name: review-vcpkg-prs-today
description: Review open non-draft microsoft/vcpkg pull requests updated in the last 30 days. Use when asked for batch triage, per-PR review reports, an index grouped by verdict, or grouping competing PRs that modify the same port.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `investigation-root` | No | Preferred directory for large temporary work such as detached worktrees, extracted archives, build trees, example builds, installs, caches, and other investigation artifacts. Final review deliverables are not investigation artifacts and must still be written under `reviews/` in the caller's current directory. When omitted, infer a short same-drive investigations location if that is clear; otherwise ask the user. Do not use the Copilot session directory or an arbitrary long temp path. |
| `review-depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Example invocations

- `/review-vcpkg-prs-today investigation-root D:/vcpkg-prs`
- `/review-vcpkg-prs-today review-depth examples`
- `/review-vcpkg-prs-today investigation-root D:/vcpkg-prs and review-depth examples`

## Procedure

1. Discover candidate PRs with the GitHub Search API or `gh api`, not by paging the generic pulls list. Filter to:
   - `repo:microsoft/vcpkg`
   - `is:pr`
   - `is:open`
   - `draft:false`
   - `updated:>=<today minus 30 days>`
2. Prefer authenticated GitHub requests via `gh` or `GITHUB_TOKEN`, because unauthenticated API limits are usually too low for a full batch run.
3. For each candidate PR, fetch the changed file list and identify touched ports from paths matching `ports/<portname>/`.
4. Treat the competing-PR relationship as port-specific. Group PRs together only for the particular shared port or ports they both modify.
5. Keep PRs that do not modify a port in a separate index section instead of mixing them into port-competition groups.
6. Evaluate each candidate PR independently according to the rules in .github/skills/shared/review-vcpkg-pr-guide.md. Be sure each worker reads all of .github/skills/shared/review-vcpkg-pr-guide.md. Competing PRs that touch the same port are still reviewed as separate PRs; only group them in the final `index.md`.
7. Write each per-PR report as you complete it. Write `index.md` last, after aggregating the final results from every reviewed PR directory and adding any port-specific competing-PR groups.

## Parallel execution safety

1. A worker that checks out a PR, uses `gh pr checkout`, edits files, or creates build trees must do so only inside its own isolated workspace, not in the calling repository.
2. Never point multiple workers at the same writable repository path, even if they are reviewing different PRs.
3. Use detached worktrees or equivalent detached-HEAD checkouts for workers so that review activity does not change the caller's branch state. When setting up a worker, copy vcpkg.exe (windows) or vcpkg (non-Windows) into the worker's isolated workspace. For example, after `git worktree add D:\vcpkg2 origin/master`, copy `.\vcpkg.exe` to `D:\vcpkg2`.
4. Do not use the shared current working tree for concurrent PR reviews unless exactly one worker is active and the user explicitly allows it.
5. If you need a clean baseline for multiple workers, create the isolated workspaces first and then launch the workers against those paths.

## index.md content

`index.md` must include:

1. Coverage summary, including how many PRs were reviewed, skipped, or failed.
2. PRs grouped by recommended action as described in .github/skills/shared/review-vcpkg-pr-guide.md
   - `approve`
   - `approve-with-notes`
   - `request-changes`
   - `unknown`
3. Competing PRs grouped by shared modified port.
4. PRs with no touched `ports/<portname>/` entries.
5. PRs that failed to review, with a short reason instead of silently omitting them.

## cleanup-worktrees.ps1 content

If temporary worktrees were created during the review process, write this script with one `git worktree remove` line per worktree. If this file is already present, append to it. Skip this file when no temporary worktrees were created.

## Required output layout

Write all deliverables under `reviews/` in the caller's current directory, not under `investigation-root`. Each worker reviews one PR and substitutes its number for `{{PR_NUMBER}}`. Find out what report.md is from .github/skills/shared/review-vcpkg-pr-guide.md

```text
reviews/
├── index.md
├── cleanup-worktrees.ps1  (only when temporary worktrees were created)
├── pr-12345/
│   ├── report.md
│   └── patches/
│       └── *.patch
└── pr-12346/
    ├── report.md
```

Do not stop until `reviews/index.md` and `reviews/pr-{{PR_NUMBER}}/report.md` for each reviewed PR number exist and are complete. If temporary worktrees were created, also ensure `reviews/cleanup-worktrees.ps1` exists and is complete.
