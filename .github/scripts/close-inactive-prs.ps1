#Requires -Version 7.0

param(
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Age = 120,

    [string]$Repo = 'microsoft/vcpkg',

    [ValidateRange(1, [int]::MaxValue)]
    [int]$Limit = 1000,

    [string]$OutputFile,

    [ValidateScript({
        if ($_ -and -not (Test-Path -LiteralPath $_ -PathType Leaf)) {
            throw '-CloseWithComment requires a valid markdown file path.'
        }

        $true
    })]
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
        [int]$Limit,

        [Parameter(Mandatory)]
        [string]$CutoffDate
    )

    $searchQuery = "is:pr updated:<$CutoffDate -label:$NoStaleLabel sort:updated-asc"
    $command = @('pr', 'list', '--repo', $Repo, '--state', 'open', '--limit', $Limit.ToString(), '--search', $searchQuery, '--json', 'number,title,url,updatedAt,labels,author')
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

function Write-CandidateReport {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][int]$AgeDays
    )

    $labels = @($Pr.labels | ForEach-Object { $_.name })
    $labelText = if ($labels.Count -gt 0) { ($labels | Sort-Object -Unique) -join ', ' } else { '(none)' }
    $age = Get-AgeDays -UpdatedAt $Pr.updatedAt
    $authorObject = $Pr['author']
    $author = if ($authorObject -and $authorObject.Contains('login')) { [string]$authorObject['login'] } else { '(unknown)' }

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

function Test-GhAuthentication {
    $result = Invoke-GhCommand -Arguments @('auth', 'status')

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "GitHub CLI is not authenticated. Run 'gh auth login' first. $message"
    }
}

function Close-PullRequest {
    param(
        [Parameter(Mandatory)][hashtable]$Pr,
        [Parameter(Mandatory)][string]$Repo,
        [ValidateScript({ -not $_ -or (Test-Path -LiteralPath $_ -PathType Leaf) })]
        [string]$CommentFile
    )

    $command = @('pr', 'close', [string]$Pr.number, '--repo', $Repo)
    if ($CommentFile) {
        $comment = Get-Content -LiteralPath $CommentFile -Raw
        $command += @('--comment', $comment)
    }

    $result = Invoke-GhCommand -Arguments $command

    if ($result.ExitCode -ne 0) {
        $message = ($result.Output | Out-String).Trim()
        throw "Unable to close PR #$($Pr.number): $message"
    }

    return ($result.Output | Out-String)
}

function Main {
    $reportLines = [System.Collections.Generic.List[string]]::new()
    $resolvedRepo = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { $Repo }

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "'gh' is not available on PATH."
        return 1
    }

    Test-GhAuthentication
    $cutoffDate = (Get-Date).ToUniversalTime().AddDays(-$Age).ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
    $prs = Get-GhPrList -Repo $resolvedRepo -Limit $Limit -CutoffDate $cutoffDate

    $stalePrs = @($prs | Sort-Object { [datetime]::Parse($_.updatedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal) })

    if ($stalePrs.Count -eq 0) {
        Write-ReportLine -Text "No open PRs with no activity for $Age days or more found in $resolvedRepo." -ReportLines $reportLines
        
        if ($OutputFile) {
            $directory = Split-Path -Path $OutputFile -Parent
            if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }

            Set-Content -LiteralPath $OutputFile -Value $reportLines -Encoding utf8NoBOM
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
            Close-PullRequest -Pr $pr -Repo $resolvedRepo -CommentFile $CloseWithComment | Out-Null
            Write-ReportLine -Text "  closed PR #$($pr.number) via gh pr close" -ReportLines $reportLines
        }
        else {
            Write-ReportLine -Text "  would close PR #$($pr.number); pass -CloseWithComment to close it" -ReportLines $reportLines
        }
    }

    if ($OutputFile) {
        $directory = Split-Path -Path $OutputFile -Parent
        if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        Set-Content -LiteralPath $OutputFile -Value $reportLines -Encoding utf8NoBOM
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    exit (Main)
}
