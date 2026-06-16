param(
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Age = 120,

    [string]$Repo = 'microsoft/vcpkg',

    [ValidateRange(1, [int]::MaxValue)]
    [int]$Limit = 1000,

    [string]$OutputFile,

    [string]$CloseWithComment
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$NoStaleLabel = 'no-stale'

function Invoke-GhCommand {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $previousGhToken = $env:GH_TOKEN
    $previousGithubToken = $env:GITHUB_TOKEN

    Remove-Item Env:GH_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue

    try {
        $output = & gh @Arguments 2>&1
        return @{ Output = $output; ExitCode = $LASTEXITCODE }
    }
    finally {
        if ($null -eq $previousGhToken) {
            Remove-Item Env:GH_TOKEN -ErrorAction SilentlyContinue
        }
        else {
            $env:GH_TOKEN = $previousGhToken
        }

        if ($null -eq $previousGithubToken) {
            Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
        }
        else {
            $env:GITHUB_TOKEN = $previousGithubToken
        }
    }
}

function Get-GhPrList {
    param(
        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(Mandatory)]
        [int]$Limit
    )

    $command = @('pr', 'list', '--repo', $Repo, '--state', 'open', '--limit', $Limit.ToString(), '--json', 'number,title,url,updatedAt,labels,author')
    $result = Invoke-GhCommand -Arguments $command

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "Unable to list PRs with gh: $message"
    }

    return ($result.Output | Out-String) | ConvertFrom-Json -AsHashtable
}

function Get-AgeDays {
    param([Parameter(Mandatory)][string]$UpdatedAt)

    $updatedUtc = [datetime]::Parse(
        $UpdatedAt,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    )

    return [int][Math]::Floor(((Get-Date).ToUniversalTime() - $updatedUtc).TotalDays)
}

function Get-PropertyValue {
    param(
        [Parameter(Mandatory)][object]$InputObject,
        [Parameter(Mandatory)][string]$Name,
        [object]$Default = ''
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        if ($InputObject.Contains($Name)) {
            return $InputObject[$Name]
        }

        return $Default
    }

    $property = $InputObject.PSObject.Properties[$Name] -as [System.Management.Automation.PSNoteProperty]
    if ($null -ne $property) {
        return $property.Value
    }

    return $Default
}

function Test-StalePullRequest {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][int]$AgeDays
    )

    $labels = @($Pr.labels | ForEach-Object { $_.name })
    if ($NoStaleLabel -in $labels) {
        return $false
    }

    return [bool]((Get-AgeDays -UpdatedAt $Pr.updatedAt) -ge $AgeDays)
}

function Write-CandidateReport {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][int]$AgeDays
    )

    $labels = @($Pr.labels | ForEach-Object { $_.name })
    $labelText = if ($labels.Count -gt 0) { ($labels | Sort-Object -Unique) -join ', ' } else { '(none)' }
    $age = Get-AgeDays -UpdatedAt $Pr.updatedAt
    $authorObject = Get-PropertyValue -InputObject $Pr -Name 'author' -Default @{}
    $author = if ($authorObject -is [System.Collections.IDictionary] -and $authorObject.Contains('login')) { [string]$authorObject['login'] } elseif ($authorObject -and $authorObject.PSObject.Properties['login']) { [string]$authorObject.login } else { '(unknown)' }

    return @(
        "PR #$($Pr.number): $($Pr.title)",
        "  author: $author",
        "  last updated $age days ago (threshold: $AgeDays days)",
        "  labels: $labelText",
        "  url: $($Pr.url)"
    ) -join [Environment]::NewLine
}

function Write-ReportLine {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [System.Collections.Generic.List[string]]$ReportLines
    )

    if ($null -ne $ReportLines) {
        $ReportLines.Add($Text)
    }

    [Console]::WriteLine($Text)
}

function Save-Report {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string[]]$Lines
    )

    $directory = Split-Path -Path $Path -Parent
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $content = ($Lines -join [Environment]::NewLine)
    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}

function Read-CommentFile {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Comment file not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw
}

function Test-CloseRequirements {
    param(
        [string]$CloseWithComment
    )

    if ($CloseWithComment -and -not (Test-Path -LiteralPath $CloseWithComment -PathType Leaf)) {
        throw '-CloseWithComment requires a valid markdown file path.'
    }
}

function Test-GhAuthentication {
    $result = Invoke-GhCommand -Arguments @('auth', 'status')

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "GitHub CLI is not authenticated. Run 'gh auth login' first. $message"
    }
}

function Add-PrComment {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$CommentFile
    )

    $null = Read-CommentFile -Path $CommentFile
    $command = @('pr', 'comment', [string]$Pr.number, '--repo', $Repo, '--body-file', $CommentFile)
    $result = Invoke-GhCommand -Arguments $command

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "Unable to comment on PR #$($Pr.number): $message"
    }

    return ($result.Output | Out-String)
}

function Close-PullRequest {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][string]$Repo
    )

    $command = @('pr', 'close', [string]$Pr.number, '--repo', $Repo)
    $result = Invoke-GhCommand -Arguments $command

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "Unable to close PR #$($Pr.number): $message"
    }

    return ($result.Output | Out-String)
}

function Invoke-CommentAndClose {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$CommentFile
    )

    Add-PrComment -Pr $Pr -Repo $Repo -CommentFile $CommentFile | Out-Null
    Close-PullRequest -Pr $Pr -Repo $Repo | Out-Null
}

function Main {
    $reportLines = [System.Collections.Generic.List[string]]::new()
    $resolvedRepo = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { $Repo }

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "'gh' is not available on PATH."
        exit 1
    }

    try {
        Test-CloseRequirements -CloseWithComment $CloseWithComment
        Test-GhAuthentication
        $prs = Get-GhPrList -Repo $resolvedRepo -Limit $Limit
    }
    catch {
        Write-Error $_.Exception.Message
        exit 1
    }

    $stalePrs = @($prs | Where-Object { Test-StalePullRequest -Pr $_ -AgeDays $Age })

    if ($stalePrs.Count -eq 0) {
        Write-ReportLine -Text "No open PRs with no activity for $Age days or more found in $resolvedRepo." -ReportLines $reportLines
        if ($OutputFile) {
            Save-Report -Path $OutputFile -Lines @($reportLines)
        }
        return
    }

    Write-ReportLine -Text "Found $($stalePrs.Count) stale PR(s) in $resolvedRepo (threshold: $Age days since last update):" -ReportLines $reportLines
    Write-ReportLine -Text '' -ReportLines $reportLines

    foreach ($pr in $stalePrs) {
        $reportText = Write-CandidateReport -Pr $pr -AgeDays $Age
        Write-ReportLine -Text $reportText -ReportLines $reportLines
        Write-ReportLine -Text '' -ReportLines $reportLines

        if ($CloseWithComment) {
            try {
                Invoke-CommentAndClose -Pr $pr -Repo $resolvedRepo -CommentFile $CloseWithComment | Out-Null
                Write-ReportLine -Text "  closed PR #$($pr.number) via gh pr close" -ReportLines $reportLines
            }
            catch {
                $message = $_.Exception.Message
                if ($message -like 'Unable to comment on PR #*') {
                    Write-Error "Error commenting on PR #$($pr.number): $message"
                }
                else {
                    Write-Error "Error closing PR #$($pr.number): $message"
                }
                exit 1
            }
        }
    }

    if ($OutputFile) {
        Save-Report -Path $OutputFile -Lines @($reportLines)
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Main
}
