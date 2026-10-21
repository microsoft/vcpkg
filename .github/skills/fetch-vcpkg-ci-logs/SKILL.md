---
name: fetch-vcpkg-ci-logs
metadata:
   version: 2026-08-14
description: >
  Fetch vcpkg Azure DevOps metadata, failed-step logs, and selected artifacts.
  Use for acquiring CI evidence, not diagnosing or reporting regressions; use
  analyze-ci-failures for those tasks. Skip when supplied logs are sufficient.
---

# Fetch vcpkg CI Logs

First read and follow `.\.github\skills\shared\azure-vcpkg-ci-notes.md`. For endpoint shapes, artifact
naming, and ZIP layout, see [references/azure-devops-api.md](references/azure-devops-api.md).

## Prerequisites

- PowerShell with network access. The `vcpkg/public` Azure DevOps project is anonymously readable, so
  no Azure credentials are needed.
- GitHub access (`gh` CLI or the GitHub MCP server) — required only to resolve a PR number to its head
  SHA and check runs.

## Inputs

An Azure build URL/ID or microsoft/vcpkg PR URL/number, optionally narrowed by job ID, triplet,
port, or artifact.

## Workflow

1. Resolve the build ID from the Azure URL or the PR head SHA's check runs. Preserve `jobId` or `j`.
2. Fetch metadata, timeline, and artifacts in parallel.
3. Fetch failed-step logs first by directly invoking:

   ```powershell
   & '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -BuildId <id>
   & '.\.github\skills\shared\Get-VcpkgAzureFailureLogs.ps1' -PrNumber <pr> [-JobId <job>]
   ```

   Save its raw output as `failed-step-logs.txt`. Ensure every failed `Validate version files` timeline
   record is included; if the helper omits one, fetch its exact `log.url` and append the raw body.
4. Unless only step logs were requested, download relevant `failure logs for {triplet}` ZIPs from each
   artifact's `resource.downloadUrl`. Narrow by the requested job, triplet, or port; fetch other
   artifacts only when requested. Skip `file lists for {triplet}` unless asked.
5. Extract each ZIP into `artifacts/{triplet}/`. Keep only the ZIPs that were requested, and record any
   download or extraction failure with the artifact name and URL instead of retrying indefinitely.
6. Return the save location, build ID/status, Azure and PR URLs, PR title/author for PR builds,
   failed jobs/triplets, and errors.

## Downloading Rules

- Download ZIPs with `Invoke-WebRequest -UseBasicParsing` or curl. `web_fetch` **cannot** download
  binary content.
- Artifacts are `PipelineArtifact`, not `Container`; use `resource.downloadUrl` directly. The Container
  API does not work for them.
- Each ZIP contains one top-level folder named exactly `failure logs for {triplet}`, with one
  subdirectory per failing port.

## Storage

Store evidence under the session folder provided in the environment context, never relative to the
repository working directory:

```text
{session-folder}/files/ci-failure-logs/build-{buildId}/
├── metadata.json
├── timeline.json
├── artifacts.json
├── failed-step-logs.txt
└── artifacts/{triplet}/
```

Prefer the narrowest sufficient scope. Record artifact names and download errors. Do not diagnose
failures.
