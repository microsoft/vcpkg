[CmdletBinding(DefaultParameterSetName = 'ByPr')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByPr')]
    [int]$PrNumber,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByBuild')]
    [int]$BuildId,

    [string]$JobId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-QueryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $match = [regex]::Match($Text, "(?:\?|&)$([regex]::Escape($name))=([^&]+)")
        if ($match.Success) {
            return [System.Uri]::UnescapeDataString($match.Groups[1].Value)
        }
    }

    return $null
}

function Get-DescendantRecordIds {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Records,

        [Parameter(Mandatory = $true)]
        [string]$RootId
    )

    $childrenByParent = @{}
    foreach ($record in $Records) {
        if (-not $record.parentId) {
            continue
        }

        if (-not $childrenByParent.ContainsKey($record.parentId)) {
            $childrenByParent[$record.parentId] = [System.Collections.Generic.List[string]]::new()
        }

        $childrenByParent[$record.parentId].Add([string]$record.id)
    }

    $pending = [System.Collections.Generic.Stack[string]]::new()
    $result = [System.Collections.Generic.HashSet[string]]::new()
    $pending.Push($RootId)

    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        if (-not $result.Add($current)) {
            continue
        }

        if ($childrenByParent.ContainsKey($current)) {
            foreach ($childId in $childrenByParent[$current]) {
                $pending.Push($childId)
            }
        }
    }

    return $result
}

function Resolve-BuildsFromPr {
    param(
        [Parameter(Mandatory = $true)]
        [int]$PullRequestNumber
    )

    $githubHeaders = @{
        'User-Agent' = 'vcpkg-pr-review-skill'
        Accept       = 'application/vnd.github+json'
    }

    $prInfo = Invoke-RestMethod -Headers $githubHeaders -Uri "https://api.github.com/repos/microsoft/vcpkg/pulls/$PullRequestNumber"
    $checks = Invoke-RestMethod -Headers $githubHeaders -Uri "https://api.github.com/repos/microsoft/vcpkg/commits/$($prInfo.head.sha)/check-runs?per_page=100"
    $azureChecks = @($checks.check_runs | Where-Object { $_.name -like 'microsoft.vcpkg.pr*' })

    if ($azureChecks.Count -eq 0) {
        throw "No microsoft.vcpkg.pr* GitHub check runs were found for PR #$PullRequestNumber."
    }

    return @(
        foreach ($azureCheck in $azureChecks) {
            $detailsUrl = [string]$azureCheck.details_url
            $resolvedBuildId = Get-QueryValue -Text $detailsUrl -Names @('buildId')
            if (-not $resolvedBuildId) {
                Write-Warning "Skipping check '$($azureCheck.name)' because no buildId was found in details_url: $detailsUrl"
                continue
            }

            [pscustomobject]@{
                CheckName = [string]$azureCheck.name
                BuildId   = [int]$resolvedBuildId
                JobId     = if ($JobId) { $JobId } else { Get-QueryValue -Text $detailsUrl -Names @('jobId', 'j') }
                PrNumber  = $PullRequestNumber
            }
        }
    )
}

function Get-FailedRecordsToRead {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Records,

        [string]$EffectiveJobId
    )

    $recordsToRead = @()

    if ($EffectiveJobId) {
        $jobIds = Get-DescendantRecordIds -Records $Records -RootId $EffectiveJobId
        $recordsToRead = @(
            $Records | Where-Object {
                $jobIds.Contains([string]$_.id) -and $_.log -and $_.log.url -and $_.result -eq 'failed'
            }
        )

        if ($recordsToRead.Count -eq 0) {
            Write-Warning "No failed timeline records with logs were found for job id '$EffectiveJobId'."
        }
    }

    if ($recordsToRead.Count -eq 0) {
        $recordsToRead = @(
            $Records | Where-Object {
               $nameProperty = $_.PSObject.Properties['name']
               $displayNameProperty = $_.PSObject.Properties['displayName']

               $_.result -eq 'failed' -and
               $_.log -and
               $_.log.url -and
               (
                   ($nameProperty -and [string]$nameProperty.Value -like '*** Test Modified Ports*') -or
                   ($displayNameProperty -and [string]$displayNameProperty.Value -like '*** Test Modified Ports*')
               )
            }
        )
    }

    if ($recordsToRead.Count -eq 0) {
        $recordsToRead = @(
            $Records | Where-Object { $_.result -eq 'failed' -and $_.log -and $_.log.url }
        )
    }

    return $recordsToRead
}

$targets = if ($PSCmdlet.ParameterSetName -eq 'ByPr') {
    Resolve-BuildsFromPr -PullRequestNumber $PrNumber
} else {
    @(
        [pscustomobject]@{
            CheckName = 'direct-build'
            BuildId   = $BuildId
            JobId     = $JobId
            PrNumber  = $null
        }
    )
}

foreach ($target in $targets) {
    $timeline = Invoke-RestMethod -Uri "https://dev.azure.com/vcpkg/public/_apis/build/builds/$($target.BuildId)/timeline?api-version=7.0"
    $records = @($timeline.records)
    $recordsToRead = Get-FailedRecordsToRead -Records $records -EffectiveJobId $target.JobId

    if ($recordsToRead.Count -eq 0) {
        Write-Warning "No failed timeline records with logs were found for build $($target.BuildId)."
        continue
    }

    Write-Output "===== check: $($target.CheckName) ====="
    if ($target.PrNumber) {
        Write-Output "PR: #$($target.PrNumber)"
    }
    Write-Output "Build: https://dev.azure.com/vcpkg/public/_build/results?buildId=$($target.BuildId)"
    if ($target.JobId) {
        Write-Output "JobId: $($target.JobId)"
    }

    foreach ($record in $recordsToRead) {
        $logText = (Invoke-WebRequest -UseBasicParsing -Uri $record.log.url -Headers @{ Accept = 'text/plain' }).Content
        Write-Output ""
        Write-Output "===== $($record.name) / log $($record.log.id) ====="
        Write-Output $logText
    }
}
