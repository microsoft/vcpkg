---
name: fix-reviewed-vcpkg-pr
description: >-
  Address findings in an existing report produced by review-vcpkg-pr or
  review-vcpkg-prs-today, then push fixes for the user to submit to the
  contributor. Use only for follow-up fixes to those reviews, including
  batches. Do not use for generic bug fixes, issue resolution, or PRs
  without an existing review report. Never open a PR.
---

## Goal

Make the requested fixes on the contributor's PR head, validate and push them to the user's fork, and return a URL for the user to open a PR against the contributor's branch. Confirm whether the resulting contributor PR merits `approve`; report remaining issues or uncertainty honestly.

## Prerequisite

Before modifying anything for a PR, locate and read its existing report from `review-vcpkg-pr` or `review-vcpkg-prs-today`. If it cannot be found, ask for its location and do not proceed for that PR. Do not substitute a fresh review for this prerequisite.

## Inputs

| Input | Required | Meaning |
|---|---|---|
| `pr` | Yes | One or more microsoft/vcpkg PR numbers. |
| `fixes` | No | Requested changes per PR. If omitted, use agreed findings from the conversation or existing review; ask if the intended scope is unclear. |
| `reviews-root` | No | Directory containing `pr-<NUMBER>/report.md`; defaults to `reviews/` in the caller's original directory. |
| `push-remote` | No | Git remote for the user's fork. Use an applicable personal default or ask; do not assume `origin` is the destination. |

Resolve explicit arguments before personal defaults. Personal instructions may supply defaults scoped to microsoft/vcpkg; no particular username, remote name, or machine path is required by this skill.

Before changing directories, resolve `reviews-root` and `.github/skills/shared/review-vcpkg-pr-guide.md` against the caller's original directory to absolute paths. Resolve the push remote's URL from the caller's repository; do not assume its name has the same meaning in another workspace.

### Example invocations

- `/fix-reviewed-vcpkg-pr 12345`
- `/fix-reviewed-vcpkg-pr 12345, 12346 push-remote my-fork`
- `/fix-reviewed-vcpkg-pr 12345 reviews-root D:\review-results\reviews fixes F1,F3`
- `/fix-reviewed-vcpkg-pr 12345 fixes "Correct the installed include paths" push-remote my-fork`

## Workspace and artifact safety

Derive each PR's worktree and investigation paths from its fix handoff. Reuse the worktree when suitable; inspect its status and history first. Discard the review's uncommitted experimental changes in that worktree, but preserve previous fix commits and fix branches. If the origin of uncommitted changes is unclear, ask before discarding them. Limit cleanup to those source changes; retain review artifacts and build evidence. If a new worktree is needed, create it under the recorded investigation directory when suitable; otherwise ask for a short replacement location and resolve it to an absolute path. Never use the Copilot session directory or an arbitrary long temp path. Never switch branches or run mutable fix/build steps in the caller's working tree.

Copy the caller's `vcpkg.exe` (Windows) or `vcpkg` (non-Windows) into the workspace root if needed. Keep builds, installs, logs, and examples worker-local and retain them for follow-up; do not use `--clean-after-build`.

If `VCPKG_DOWNLOADS` is already nonempty, preserve it for every command and worker. Use that shared directory only through vcpkg; never clean or delete it, even under storage pressure. Otherwise, do not set it. Do not pass `--downloads-root`.

Treat all existing review artifacts, including reports, patches, and the index, as read-only. Give concurrent workers separate writable workspaces and intermediate directories. Pass each worker its PR number, fix scope or finding IDs, absolute report, workspace, investigation, and guide paths, and push destination explicitly.

## Procedure

1. Read `pr-<NUMBER>/report.md` under `reviews-root`, including any `## Fix handoff`. Use its finding IDs, scope, workspace inventory, and reproduction recipes rather than relying on prior chat. Fetch current PR metadata and conversation; compare the current contributor repository, branch, and head SHA with the report. Revalidate findings affected by intervening changes. If the existing report is incomplete, reconstruct needed evidence from the PR and sources; ask about ambiguous fix scope rather than guessing. If local artifacts are missing, recreate them from the recorded recipes. If the PR is closed or its head is unavailable, report that instead of preparing a stale fix.
2. Read the shared review guide and apply its review criteria and relevant validation guidance. This is a fix workflow: do not invoke its report-writing, Contributor Feedback, or `git format-patch` deliverables. Read `.github/pull_request_template.md` and verify applicable checklist items; do not invent checklist completion.
3. Base the fix branch on the contributor's current head, not the vcpkg target branch or a synthetic merge commit. Name the destination branch `pr-<NUMBER>-<PORT>`; use a short descriptive suffix for multi-port or non-port changes. Check for existing local and remote fix branches and preserve prior fixes. Apart from the review's uncommitted experimental changes described above, ask before discarding work or rewriting published history.
4. Make only the requested fixes and tightly coupled corrections. Distinguish introduced problems from pre-existing ones; do not expand into unrelated repairs just to obtain an approval verdict. Generate or refresh source patch files with `git diff --output=<patch-file>`, preserving line endings. Do not open upstream PRs either; report any upstream-submission requirement that remains unmet.
5. Validate the changed behavior with relevant builds and consumer examples, reusing review evidence only where still applicable. For integration fixes, cover Release and Debug and affected integration methods using the guide's rules. Surface failed or unavailable validation explicitly.
6. Keep versioning consistent with the contributor's PR. Do not add another `port-version` bump when the PR already introduces the version entry being fixed. After committing port changes, refresh each affected entry with `vcpkg x-add-version <port> --overwrite-version` when replacing that PR's entry, then commit the generated metadata. Do not overwrite historical entries already in the target branch. Verify the final version records match the final port contents.
7. Assess the resulting contributor PR against the review criteria, including remaining findings. State whether it would receive `approve`; if not, give its actual verdict and reasons. Do not alter the original review artifacts.
8. Before pushing, recheck the contributor's head and verify that the commits being added contain only the intended fixes. If the head moved, update safely, repeat affected validation, and repeat step 7's verdict assessment before proceeding. Verify the push URL belongs to the intended user-controlled fork, not the contributor's repository or microsoft/vcpkg. Push the fix branch without force and verify its remote tip matches the local commit. Report push failures as failures.
9. Generate a PR creation URL using the contributor repository and branch as the base and the pushed fork branch as the head. Do not target microsoft/vcpkg's default branch. Never open a PR or post review comments; submission belongs to the user.

## Required result

For every requested PR, return its fix summary, worktree path, pushed branch and commit, validation results or limitations, resulting review verdict, and contributor-targeted PR creation URL. For batches, account for every PR, including blocked or failed fixes.

Finish only after the intended commits are pushed and verified, or explicitly report what prevented completion. Leave all review artifacts unchanged and open no PRs.
