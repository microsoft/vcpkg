---
name: review-vcpkg-prs-today
description: Review open non-draft microsoft/vcpkg pull requests updated in the last 30 days. Use when asked for batch triage, per-PR review reports, an index grouped by verdict, or grouping competing PRs that modify the same port.
disable-model-invocation: true
---

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `investigation-root` | No | Directory for PR worktrees and intermediate artifacts: sources, builds, installs, logs, and examples. Defaults to `.worktrees` at the root of the caller's working tree, which is the path printed by `git rev-parse --show-toplevel` in the caller's original directory. Never use the Copilot session directory or an arbitrary long temp path. |

### Example invocations

- `/review-vcpkg-prs-today investigation-root D:/vcpkg-prs`

## Procedure

1. Before changing directories, resolve `investigation-root`, `reviews/`, and `.github/skills/shared/review-vcpkg-pr-guide.md` against the caller's original directory to absolute paths. Keep the resolved reviews directory as `reviews-root`; never rebase it onto a worker's workspace.
2. Discover candidates using GitHub search (`gh api` or the Search API), not the generic pulls list: `repo:microsoft/vcpkg is:pr is:open draft:false updated:>=<today minus 30 days>`. Prefer authentication via `gh` or `GITHUB_TOKEN` to avoid low unauthenticated limits.
3. Fetch each candidate's changed files; identify ports from `ports/<portname>/`.
4. Prepare isolated workspaces as below. Review every candidate independently with a `general-purpose` worker using its default high-capability model; do not override it with a fast or lightweight model. Require it to read the entire guide and follow every instruction. Group competition only in the index. Pass each worker:
   - PR number (`{{PR_NUMBER}}`).
   - Absolute worktree (`pr-{{PR_NUMBER}}` under `investigation-root`) and worker-local `investigation-root` (`pr-{{PR_NUMBER}}-artifacts` under `investigation-root`).
   - Absolute `{{REPORT_DIR}}` (`pr-{{PR_NUMBER}}` under `reviews-root`).
   - Absolute guide path.
5. As each review completes, write its report and immediately update `index.md` with that result before waiting for another review. The coordinator is the sole index writer; workers must not write it. Keep the index accurate as results arrive, including pending, skipped, and failed PRs, and update it when a review is skipped or fails. After all reviews finish, reconcile the index against the final per-PR results and port-specific competition groups.

## Parallel execution safety

1. Give each concurrent worker its own linked worktree of the caller's repository, not a clone or copy. Never share a writable repository path between workers. Invoking this skill explicitly requests these worktrees.
2. Create all worktrees at their PR heads with `git worktree add --detach` before launching workers. If one already exists, detach it at the PR head instead; preserve its branches and commits, and ask before discarding uncommitted changes whose origin is unclear. Copy the caller's `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into each worktree root.
3. Use the caller's working tree only when exactly one worker is active and the user explicitly allows it.
4. If `VCPKG_DOWNLOADS` is already nonempty, preserve it for all workers and review commands. Use that shared directory only through vcpkg; never clean or delete it. Otherwise, do not set it.

## index.md content

`index.md` must include:

1. Coverage summary, including how many PRs were reviewed, pending, skipped, or failed.
2. PRs grouped by the shared guide's verdicts: `approve`, `approve-with-notes`, `request-changes`, and `unknown`, with relative links to their reports.
3. Competing PRs grouped only by the specific modified ports they share.
4. PRs with no touched `ports/<portname>/` entries.
5. PRs that failed to review, with a short reason instead of silently omitting them.

## Required output layout

Write only final deliverables under the fixed `reviews-root`, not under `investigation-root`:

1. `index.md` at `reviews-root`.
2. `report.md` in each worker's `{{REPORT_DIR}}`, including the guide's self-contained `## Fix handoff` for use without this session's chat history.

Do not stop until the index and every reviewed PR's report exist at these absolute destinations and are complete.
