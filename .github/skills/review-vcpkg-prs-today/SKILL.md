---
name: review-vcpkg-prs-today
description: Review open non-draft microsoft/vcpkg pull requests updated in the last 30 days. Use when asked for batch triage, per-PR review reports, an index grouped by verdict, or grouping competing PRs that modify the same port.
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `investigation-root` | No | Directory for workspaces and intermediate artifacts: sources, builds, installs, logs, and examples. If omitted, infer a short same-drive path when clear; otherwise ask. Never use the Copilot session directory or an arbitrary long temp path. |
| `review-depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Example invocations

- `/review-vcpkg-prs-today investigation-root D:/vcpkg-prs`
- `/review-vcpkg-prs-today review-depth examples`
- `/review-vcpkg-prs-today investigation-root D:/vcpkg-prs and review-depth examples`

## Procedure

1. Before changing directories, resolve `investigation-root`, `reviews/`, and `.github/skills/shared/review-vcpkg-pr-guide.md` against the caller's original directory to absolute paths. Keep the resolved reviews directory as `reviews-root`; never rebase it onto a worker's workspace.
2. Discover candidates using GitHub search (`gh api` or the Search API), not the generic pulls list: `repo:microsoft/vcpkg is:pr is:open draft:false updated:>=<today minus 30 days>`. Prefer authentication via `gh` or `GITHUB_TOKEN` to avoid low unauthenticated limits.
3. Fetch each candidate's changed files; identify ports from `ports/<portname>/`.
4. Prepare isolated workspaces as below. Review every candidate independently with a `general-purpose` worker using its default high-capability model; do not override it with a fast or lightweight model. Require it to read the entire guide and follow every instruction. Group competition only in the final index. Pass each worker:
   - PR number (`{{PR_NUMBER}}`).
   - Selected `review-depth`.
   - Absolute workspace and worker-local `investigation-root`.
   - Absolute `{{REPORT_DIR}}` (`pr-{{PR_NUMBER}}` under `reviews-root`).
   - Absolute guide path.
5. Write each report when completed. Write `index.md` last from the final per-PR results and port-specific competition groups.

## Parallel execution safety

1. Give each concurrent worker its own writable detached worktree or equivalent detached-HEAD workspace and intermediate artifacts under `investigation-root`. Never share a writable repository path between workers.
2. Create all isolated workspaces before launching workers. Copy the caller's `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into each workspace root.
3. Use the caller's working tree only when exactly one worker is active and the user explicitly allows it.
4. If `VCPKG_DOWNLOADS` is already nonempty, preserve it for all workers and review commands. Use that shared directory only through vcpkg; never clean or delete it. Otherwise, do not set it.

## index.md content

`index.md` must include:

1. Coverage summary, including how many PRs were reviewed, skipped, or failed.
2. PRs grouped by the shared guide's verdicts: `approve`, `approve-with-notes`, `request-changes`, and `unknown`, with relative links to their reports.
3. Competing PRs grouped only by the specific modified ports they share.
4. PRs with no touched `ports/<portname>/` entries.
5. PRs that failed to review, with a short reason instead of silently omitting them.

## Required output layout

Write only final deliverables under the fixed `reviews-root`, not under `investigation-root`:

1. `index.md` at `reviews-root`.
2. `report.md` in each worker's `{{REPORT_DIR}}`, including the guide's self-contained `## Fix handoff` for use without this session's chat history.
3. `patches/*.patch` in each worker's `{{REPORT_DIR}}` -- only for `examples-and-patches`; omit if no patches were produced and explain any unpatched issues in the report.

Do not stop until the index and every reviewed PR's report exist at these absolute destinations and are complete.
