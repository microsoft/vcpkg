# Azure DevOps REST API Reference for vcpkg CI

## Base URL

```
https://dev.azure.com/vcpkg/public/_apis
```

All endpoints below are appended to this base. The `vcpkg/public` project is **publicly readable** — no Authorization header is required.

## API Version

Always append `?api-version=7.0` (or include it in query strings).

---

## Build Endpoints

### Get Build Details

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}?api-version=7.0
```

**Response fields:**
```json
{
  "id": 129315,
  "buildNumber": "20240315.1",
  "status": "completed",
  "result": "failed",
  "reason": "pullRequest",
  "sourceBranch": "refs/pull/12345/merge",
  "sourceVersion": "abc123def456...",
  "requestedFor": { "displayName": "Jane Developer" },
  "startTime": "2024-03-15T10:00:00Z",
  "finishTime": "2024-03-15T14:30:00Z",
  "definition": { "name": "vcpkg.CI" },
  "_links": {
    "web": { "href": "https://dev.azure.com/vcpkg/public/_build/results?buildId=129315" }
  }
}
```

**`result` values:** `succeeded` | `failed` | `partiallySucceeded` | `canceled`
**`reason` values:** `pullRequest` | `schedule` | `manual` | `individualCI` | `batchedCI`

---

### Get Build Timeline

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/timeline?api-version=7.0
```

Returns all stages, jobs, tasks and their results.

**Response structure:**
```json
{
  "records": [
    {
      "id": "guid",
      "parentId": "parent-guid-or-null",
      "type": "Job",
      "name": "x64_windows",
      "displayName": "x64_windows",
      "state": "completed",
      "result": "failed",
      "startTime": "2024-03-15T10:05:00Z",
      "finishTime": "2024-03-15T12:15:00Z",
      "log": {
        "id": 42,
        "type": "Container",
        "url": "https://dev.azure.com/vcpkg/public/_apis/build/builds/129315/logs/42"
      },
      "errorCount": 1,
      "warningCount": 0
    }
  ]
}
```

**`type` values:** `Stage` | `Phase` | `Job` | `Task`
**`result` values:** `succeeded` | `failed` | `skipped` | `canceled` | `succeededWithIssues`

**To find failed jobs:**
```python
failed_jobs = [r for r in records if r['type'] == 'Job' and r['result'] == 'failed']
```

**Job names map to triplets** (underscores in job names, hyphens in triplets):
- `x64_windows` → `x64-windows`
- `x64_windows_static` → `x64-windows-static`
- `arm64_osx` → `arm64-osx`
- `x64_linux` → `x64-linux`
- `arm_neon_android` → `arm-neon-android`

---

### Get a Specific Log

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/logs/{logId}?api-version=7.0
```

Returns plain text of the log. Use this to read the "*** Test Modified Ports" task log, which contains `REGRESSION:` lines for **all** failures including those without artifact logs (e.g., `FILE_CONFLICTS`).

**Finding the right log ID:** Look up the task record in the timeline response — the `log.id` field on the `"*** Test Modified Ports"` task record gives the log ID. Alternatively, use `log.url` directly.

**Scanning for REGRESSION lines:**
```powershell
$logText = Invoke-RestMethod "https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/logs/{logId}?api-version=7.0"
$logText -split "`n" | Where-Object { $_ -match '^REGRESSION:' }
```

**Example output:**
```
REGRESSION: kf6i18n:x64-windows failed with FILE_CONFLICTS. If expected, add kf6i18n:x64-windows=fail to .../ci.baseline.txt.
REGRESSION: kf6itemmodels:x64-windows failed with FILE_CONFLICTS. If expected, add kf6itemmodels:x64-windows=fail to .../ci.baseline.txt.
REGRESSION: v8:x64-windows failed with BUILD_FAILED. If expected, add v8:x64-windows=fail to .../ci.baseline.txt.
```

> ⚠️ **`FILE_CONFLICTS` failures do NOT produce failure log artifacts.** The only record of them is in this step log. Always scan all "Test Modified Ports" task logs before relying on artifacts alone.

### List All Logs

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/logs?api-version=7.0
```

---

## Artifact Endpoints

### List All Artifacts

```
GET https://dev.azure.com/{org}/{project}/_apis/build/builds/{buildId}/artifacts?api-version=7.0
```

**Response:**
```json
{
  "count": 39,
  "value": [
    {
      "id": 1107682,
      "name": "failure logs for x64-windows",
      "source": "7922e5c4-...",
      "resource": {
        "type": "PipelineArtifact",
        "data": "DCCD3D9C96CE79A758B255BD87397A07371B8394EE52F6BFF35346C144D63F3501",
        "properties": {
          "RootId": "196FDE3B...",
          "artifactsize": "8586850",
          "HashType": "DEDUP1024K",
          "DomainId": "0"
        },
        "url": "https://dev.azure.com/vcpkg/.../_apis/build/builds/129315/artifacts?artifactName=failure%20logs%20for%20x64-windows&api-version=7.0",
        "downloadUrl": "https://artprodwus21.artifacts.visualstudio.com/.../_apis/artifact/{base64hash}/content?format=zip"
      }
    }
  ]
}
```

> ⚠️ **`resource.type` is `"PipelineArtifact"`**, not `"Container"`. The Container listing API
> (`GET /_apis/resources/Containers/{id}`) does **not** work for these artifacts.
> Use `resource.downloadUrl` directly to download the ZIP.

**Artifact naming conventions:**
| Artifact Name Pattern | Contents | Priority |
|---|---|---|
| `failure logs for {triplet}` | Per-port build failure log directories | **High** — primary source |
| `file lists for {triplet}` | Installed file manifests | Low — skip unless needed |
| `format.diff` | Formatting/manifest diff | **Medium** — indicates PR format issues |
| `z azcopy logs for {triplet}` | Binary cache transfer logs | Low — infrastructure only |

---

### Download Artifact ZIP (Confirmed Working)

Use the `downloadUrl` from the artifact listing. It resolves to an `artprodwus21.artifacts.visualstudio.com` URL. **`web_fetch` cannot download binary ZIPs** — use PowerShell:

```powershell
# $downloadUrl = value from resource.downloadUrl in the artifacts list response
Invoke-WebRequest -Uri $downloadUrl -OutFile "$tmpDir\{triplet}.zip" -UseBasicParsing
Expand-Archive "$tmpDir\{triplet}.zip" -DestinationPath "$tmpDir\{triplet}" -Force

# List failing ports — each is a subdirectory inside the artifact folder
$root = "$tmpDir\{triplet}\failure logs for {triplet}"
Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name
```

The ZIP always contains one top-level folder named exactly `"failure logs for {triplet}"`.
Inside that folder, each **failing port has its own subdirectory** named after the port.

> ❌ The Container API (`GET /_apis/resources/Containers/{containerId}`) does **not** work
> for `PipelineArtifact` type. Do not attempt to use it.

---

## Test Results Endpoints

### List Test Runs for a Build

```
GET https://dev.azure.com/{org}/{project}/_apis/test/runs?buildId={buildId}&api-version=7.0
```

**Response:**
```json
{
  "value": [
    {
      "id": 9876,
      "name": "x64-windows",
      "state": "Completed",
      "totalTests": 500,
      "passedTests": 497,
      "failedTests": 3
    }
  ]
}
```

### Get Test Run Results

```
GET https://dev.azure.com/{org}/{project}/_apis/test/runs/{runId}/results?api-version=7.0&outcomes=Failed
```

Filter by `outcomes=Failed` to get only failures.

**Response includes:**
- `testCaseName` — usually `portname:triplet`
- `outcome` — `Failed`
- `errorMessage` — short error description
- `stackTrace` — full failure output

---

## URL Parsing

Given `https://dev.azure.com/vcpkg/public/_build/results?buildId=129315&view=results`:

| Component | Value | How to Extract |
|-----------|-------|----------------|
| Organization | `vcpkg` | 4th path segment |
| Project | `public` | 5th path segment |
| Build ID | `129315` | `buildId` query parameter |

```python
# Python example
from urllib.parse import urlparse, parse_qs
url = "https://dev.azure.com/vcpkg/public/_build/results?buildId=129315&view=results"
parts = urlparse(url)
segments = parts.path.strip('/').split('/')
org = segments[0]       # "vcpkg"
project = segments[1]   # "public"
build_id = parse_qs(parts.query)['buildId'][0]  # "129315"
```

---

## Rate Limits and Auth

- **Public projects** (like `vcpkg/public`): No authentication needed; anonymous access is allowed
- **Rate limit**: ~200 requests per minute for anonymous; increase by adding a PAT as Bearer token if needed
- **PAT header**: `Authorization: Basic {base64(":pat_token")}`
