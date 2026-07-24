# Shared Azure CI Notes for vcpkg Skills

Read this file before doing Azure-specific work in any vcpkg skill.

## Shared rules

1. The public Azure DevOps project is `https://dev.azure.com/vcpkg/public/`.
2. Public build and timeline metadata can be read anonymously.
3. For PR-triggered builds, resolve the PR head SHA from GitHub, then inspect GitHub check runs to find the Azure `details_url` and its `buildId`.
4. If a matrix check's `details_url` contains `jobId=...` or `j=...`, use that job id to narrow timeline records for that job.
5. Otherwise start with failed `*** Test Modified Ports` records.
6. For raw log bodies, prefer the exact `record.log.url` from the timeline or `?api-version=7.1`.
7. Do **not** force `?api-version=7.0` onto log-body URLs, because that can return HTTP 500 even when the anonymous log is available.
8. `FILE_CONFLICTS` failures may exist only in the failed step logs, so scan those before relying on artifacts.
9. Artifact type is `PipelineArtifact`, not `Container`. Use the artifact `downloadUrl` directly for ZIP downloads.
10. Do **not** treat a raw `BUILD_FAILED` line by itself as a meaningful regression signal. Some build failures are expected and filtered by `ci.baseline.txt` or `ci.feature.baseline.txt`.
11. For matrix CI interpretation, prefer the filtered `REGRESSION:` lines and any feature-test `error:` lines as the meaningful summary of what actually failed review expectations.

## Shared helper script

Prefer the shared helper script when you need raw failed step logs:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr>
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -BuildId <buildId>
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr> -JobId <job-id>
```

The helper prints the matching build URL, selected failed records, and their raw logs. When writing review conclusions, summarize the meaningful `REGRESSION:` or feature-test `error:` lines rather than quoting raw package `BUILD_FAILED` lines out of context.

### Invocation rule

When using the helper, invoke the `.ps1` file directly by path with the shell or PowerShell tool. Do **not** read the script file and do **not** paste or reconstruct its contents into an inline PowerShell block. Prefer a direct file invocation such as:

```powershell
& '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -BuildId 129315
```
