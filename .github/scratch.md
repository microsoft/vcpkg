
1. Read  for common review requirements and apply them.
2. Create an example application that demonstrates:
   - `find_package`
   - `pkg-config`
   - "MSBuild Style": include only `<triplet>\include` and link all `*.lib` files, with no extra macro defines. Any needed configuration should already be baked into the installed headers.
2. If the PR adds one or more new ports, run the `evaluate-new-port` skill for each one from the PR checkout and include those audit results in `report.md` and `results.json`.
3. If you create an example app, save supporting audit notes, or produce other supporting files, keep them under `investigation-root`.
4. When you find an issue that a vcpkg maintainer could reasonably apply directly, prepare a focused validated patch for it. Create patches as real files under `report-root\patches` using `git format-patch` from commits based on the PR head. Each patch must address one issue, avoid scope creep, avoid unrelated formatting churn, and be validated against the PR head with at least `git apply --check` plus targeted build and test commands when practical. Record that validation in `results.json`.
5. It is acceptable to leave the patch directory empty when no safe focused patch is warranted. Do not fabricate patches.

## Shared helper

When Azure CI log investigation is needed, prefer:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
```


6. If the PR is a simple version bump and the only material problems you find were already present in the previous version, report "approve-with-notes".
7. When reviewing portfiles, flag direct `set(VCPKG_LIBRARY_LINKAGE ...)` mutations and prefer `vcpkg_check_linkage(...)` instead.

## Batch review depth

Apply the shared review guide to each PR, then adjust depth according to `review depth`:

1. Always produce `report.md` and `results.json` for each PR using the shared formats.
2. If a PR adds one or more new ports, run the `evaluate-new-port` skill for each new port and include those audit results in that PR's `report.md` and `results.json`.
3. If `review depth` is `no-examples`, do **not** build example applications and do **not** generate focused patches.
4. If `review depth` is `examples` or `examples-and-patches`, create an example application per PR that demonstrates:
   - `find_package`
   - `pkg-config`
   - "MSBuild Style": include only `<triplet>\include` and link all `*.lib` files, with no extra macro defines. Any needed configuration should already be baked into the installed headers.
5. If `review depth` is `examples-and-patches`, you may generate focused patches when warranted. Otherwise leave patches out of scope and set issue `patch` fields to `null`.
6. If `review depth` includes examples and `investigation root` is provided, keep example apps and other heavy temporary artifacts under `investigation root`.
7. If `review depth` includes examples and `investigation root` is omitted, keep those artifacts under the inferred same-drive investigation workspace rather than the Copilot session directory.
8. If Azure CI is relevant, use the shared helper script:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
```

When reviewing portfiles, flag direct `set(VCPKG_LIBRARY_LINKAGE ...)` mutations and prefer `vcpkg_check_linkage(...)` instead.

For simple version-bump PRs, do not treat pre-existing package problems as blocking unless the PR introduces a regression or otherwise makes the existing problem materially worse. In the per-PR report, use human wording such as "approve with notes" when appropriate, but continue to map that outcome into the shared machine-readable verdict scheme. Keep the paste-ready review comment directly postable: avoid hypothetical phrasing like `I would merge`, say instead that the note is not blocking because it predates the PR or is otherwise non-blocking, and avoid spending that short comment on PR-page-visible facts like green checks unless they are needed to interpret the finding.