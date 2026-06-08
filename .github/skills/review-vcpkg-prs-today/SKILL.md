---
name: review-vcpkg-prs-today
description: Review open non-draft microsoft/vcpkg pull requests updated in the last 30 days. Use when asked for batch triage, per-PR review reports, an index grouped by verdict, or grouping competing PRs that modify the same port.
---

# vcpkg Recent PR Batch Reviewer

First, read `.\.github\skills\shared\review-vcpkg-pr-guide.md` and follow it as the shared contract for each per-PR review.

## Inputs

Parse these from the user's request.

| Input | Required | Meaning |
|---|---|---|
| `report root` | No | Directory for final deliverables. Default to `reviews` under the current working directory. |
| `investigation root` | No | Preferred directory for large temporary work such as detached worktrees, extracted archives, build trees, installs, caches, and other investigation artifacts. When omitted, infer a short same-drive investigations location if that is clear; otherwise ask the user. |
| `review depth` | No | One of `no-examples`, `examples`, or `examples-and-patches`. Default to `no-examples`. |

### Input handling rules

1. Review open PRs in `microsoft/vcpkg` that are not draft and have been updated in the last 30 days.
2. If `report root` is omitted, resolve it to `.\reviews` from the current working directory.
3. If `investigation root` is provided, strongly prefer it for heavy temporary work.
4. If `investigation root` is omitted, prefer a short investigations path on the same drive as the initial repository instead of the Copilot session directory or an arbitrary long temp path.
5. If no suitable investigations location is clear, ask the user before creating worktrees or other heavy investigation artifacts.
6. If `review depth` is omitted, default to `no-examples`.
7. Interpret `review depth` as:
   - `no-examples`: triage review only, no example applications, no patches
   - `examples`: include example applications, but do not generate patches
   - `examples-and-patches`: include example applications and allow focused patches when warranted
8. If `report root\pr-<number>\report.md` already exists and is newer than or equal to the PR's `updated_at` timestamp, you may skip re-reviewing that PR and reuse the existing result.
9. If you use subagents or otherwise review multiple PRs in parallel, give each worker its own writable checkout. Do **not** let multiple workers share the same mutable repository directory.
10. When parallelizing, prefer one detached `git worktree` (or separate clone) per worker under `investigation root` when it is provided. If `investigation root` is omitted, create isolated same-drive workspaces at a short inferred path rather than reusing the current working tree.
11. Workers may share `report root`, but each worker should write only the deliverables for the PRs assigned to it.

### Example invocations

- `Use /review-vcpkg-prs-today and save the reports in C:\temp\reviews.`
- `Use /review-vcpkg-prs-today with report root C:\temp\reviews and investigation root D:\investigations\vcpkg-prs.`
- `Use /review-vcpkg-prs-today with review depth examples and save the reports in C:\temp\reviews.`
- `Use /review-vcpkg-prs-today with review depth examples-and-patches and report root C:\temp\reviews.`

## Discovery and indexing

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

## Parallel execution safety

1. A worker that checks out a PR, uses `gh pr checkout`, edits files, or creates build trees must do so only inside its own isolated workspace, not in the calling repository.
2. Never point multiple workers at the same writable repository path, even if they are reviewing different PRs.
3. Use detached worktrees or equivalent detached-HEAD checkouts for workers so that review activity does not change the caller's branch state.
4. Do not use the shared current working tree for concurrent PR reviews unless exactly one worker is active and the user explicitly allows it.
5. If you need a clean baseline for multiple workers, create the isolated workspaces first and then launch the workers against those paths.

## Output layout

Write all deliverables under `report root`:

```text
report root\
├── index.md
├── pr-12345\
│   ├── report.md
│   └── results.json
└── pr-12346\
    ├── report.md
    └── results.json
```

Write each per-PR report as you complete it. Write `index.md` last, after aggregating the final on-disk `results.json` files from every reviewed PR directory.

## Batch review depth

Apply the shared review guide to each PR, then adjust depth according to `review depth`:

1. Always produce `report.md` and `results.json` for each PR using the shared formats.
2. If `review depth` is `no-examples`, do **not** build example applications and do **not** generate focused patches.
3. If `review depth` is `examples` or `examples-and-patches`, create an example application per PR that demonstrates:
   - `find_package`
   - `pkg-config`
   - "MSBuild Style": include only `<triplet>\include` and link all `*.lib` files, with no extra macro defines. Any needed configuration should already be baked into the installed headers.
4. If `review depth` is `examples-and-patches`, you may generate focused patches when warranted. Otherwise leave patches out of scope and set issue `patch` fields to `null`.
5. If `review depth` includes examples and `investigation root` is provided, keep example apps and other heavy temporary artifacts under `investigation root`.
6. If `review depth` includes examples and `investigation root` is omitted, keep those artifacts under the inferred same-drive investigation workspace rather than the Copilot session directory.
7. If Azure CI is relevant, use the shared helper script:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
```

For simple version-bump PRs, do not treat pre-existing package problems as blocking unless the PR introduces a regression or otherwise makes the existing problem materially worse. In the per-PR report, use human wording such as "approve with notes" when appropriate, but continue to map that outcome into the shared machine-readable verdict scheme.

## Required index sections

`index.md` must include:

1. Coverage summary, including how many PRs were reviewed, skipped, or failed.
2. PRs grouped by recommended action:
   - `approve`
   - `approve with notes`
   - `request changes`
   - `unknown`
3. Competing PRs grouped by shared modified port.
4. PRs with no touched `ports/<portname>/` entries.
5. PRs that failed to review, with a short reason instead of silently omitting them.
