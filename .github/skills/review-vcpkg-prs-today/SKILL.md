---
name: review-vcpkg-prs-today
description: Review open non-draft microsoft/vcpkg pull requests updated in the last 30 days. Use when asked for batch triage, per-PR review reports, an index grouped by verdict, or grouping competing PRs that modify the same port.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `investigation-root` | No | Directory for large temporary artifacts such as worktrees, sources, builds, examples, and installs. Final deliverables still go under `reviews/` in the caller's current directory. If omitted, infer a short same-drive path when clear; otherwise ask. Never use the Copilot session directory or an arbitrary long temp path. |
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
2. Prefer authenticated requests via `gh` or `GITHUB_TOKEN`; unauthenticated limits are usually too low for a full batch.
3. For each candidate PR, fetch the changed file list and identify touched ports from paths matching `ports/<portname>/`.
4. Group competing PRs only by the specific port or ports they share. Put PRs that touch no port in a separate index section.
5. Review every candidate independently with a `general-purpose` worker using its default high-capability model; do not override it with a fast or lightweight model. Every worker must read all of `.github/skills/shared/review-vcpkg-pr-guide.md` and treat every instruction as mandatory. Group competing PRs only in the final `index.md`.
6. Write each report when completed. Write `index.md` last from the final per-PR results and port-specific competition groups.

## Parallel execution safety

1. Give each concurrent worker its own writable detached worktree or equivalent detached-HEAD workspace. Never share a writable repository path between workers.
2. Create all isolated workspaces before launching workers. Copy `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into each one; for example, after `git worktree add D:\vcpkg2 origin/master`, copy `.\vcpkg.exe` to `D:\vcpkg2`.
3. Use the caller's working tree only when exactly one worker is active and the user explicitly allows it.

## index.md content

`index.md` must include:

1. Coverage summary, including how many PRs were reviewed, skipped, or failed.
2. PRs grouped by the shared guide's verdicts: `approve`, `approve-with-notes`, `request-changes`, and `unknown`.
3. Competing PRs grouped by shared modified port.
4. PRs with no touched `ports/<portname>/` entries.
5. PRs that failed to review, with a short reason instead of silently omitting them.

## Required output layout

Write all deliverables under `reviews/` in the caller's current directory, not under `investigation-root`. Each worker substitutes its PR number for `{{PR_NUMBER}}`; the shared guide defines `report.md`.

```text
reviews/
├── index.md
├── pr-12345/
│   ├── report.md
│   └── patches/
│       └── *.patch
└── pr-12346/
    ├── report.md
```

Do not stop until `reviews/index.md` and `reviews/pr-{{PR_NUMBER}}/report.md` for each reviewed PR number exist and are complete.
