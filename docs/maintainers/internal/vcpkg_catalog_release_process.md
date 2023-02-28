# vcpkg_catalog_release_process

This document describes the acceptance criteria / process we use when doing a vcpkg release.

1. Generate a new GitHub Personal Access Token with repo permissions.
2. Using the PAT, invoke $/scripts/Get-Changelog.ps1 `-StartDate (previous release date) -EndDate (Get-Date) -OutFile path/to/results.md`
3. Create a new GitHub release in this repo.
4. Submit a vcpkg.ci (full tree rebuild) run with the same SHA as that release.
5. Use the "auto-generate release notes". Copy the "new contributors" and "full changelog" parts to the end of `path/to/results.md`.
6. Change `## New Contributors` to `#### New Contributors`
7. In `path/to/results.md`, update `LINK TO BUILD` with the most recent link to vcpkg.ci run.
8. In `path/to/results.md`, fill out the tables for number of existing ports and successful ports.
9. Replace the contents of the release notes with the contents of `path/to/results.md`
10. After the full rebuild submission completes, update the link to the one for the exact SHA, the counts, and remove "(tentative)".
