#Requires -Version 5.0
# We are not using Powershell >= 6.0, as the only supported debugger (vscode powershell extension) breaks on complex code. See: https://github.com/PowerShell/PowerShellEditorServices/issues/1295
# This code can be run on PowerShell Core on any platform, but it is recommend to debug this code in Windows PowerShell ISE unless debugging happens to "just work" on your machine.
# Expect the fix to be out at around the end of 2020/beginning of 2021, at which point consider upgrading this script to PowerShell 7 the next time maintenance is necessary.
# -- Griffin Downs 2020-12-15 (@grdowns)

using namespace System.Management.Automation
using namespace System.Collections.Generic

<#
.SYNOPSIS
    Changelog generator for vcpkg.
.DESCRIPTION
    The changelog generator uses GitHub's Pull Request and Files API to get
    pull requests and their associated file changes over the provided date range.
    Then, the data is processed into buckets which are presented to the user
    as a markdown file.
.EXAMPLE
    Get-Changelog
.EXAMPLE
    Get-Changelog -StartDate 11/1/20 -EndDate 12/1/20
.EXAMPLE
    $cred = Get-Credential
    Get-Changelog -Credentials $cred
.OUTPUTS
    A "CHANGELOG.md" file in the working directory. If the file already exists,
    suffix is added to the filename and a new file is created to prevent overwriting.
#>
[CmdletBinding(PositionalBinding=$True)]
Param (
    # The begin date range (inclusive)
    [Parameter(Mandatory=$True, Position=0)]
    [ValidateScript({$_ -le (Get-Date)})]
    [DateTime]$StartDate,

    # The end date range (exclusive)
    [Parameter(Mandatory, Position=1)]
    [ValidateScript({$_ -le (Get-Date)})]
    [DateTime]$EndDate,

    [Parameter(Mandatory=$True)]
    [String]$OutFile,

    # GitHub credentials (username and PAT)
    [Parameter()]
    [Credential()]
    [PSCredential]$Credentials
)

Set-StrictMode -Version 2

if (-not $Credentials) {
    $Credentials = Get-Credential -Message 'Enter GitHub Credentials (username and PAT)'
    if (-not $Credentials) {
        throw [System.ArgumentException]::new(
            'Cannot process command because of the missing mandatory parameter: Credentials.'
        )
    }
}

function Get-AuthHeader() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [Credential()]
        [PSCredential]$Credentials
    )
    @{ Authorization = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(
        "$($Credentials.UserName):$($Credentials.GetNetworkCredential().Password)")) }
}

$response = Invoke-WebRequest -uri 'https://api.github.com' -Headers (Get-AuthHeader $Credentials)
if ('X-OAuth-Scopes' -notin $response.Headers.Keys) {
    throw [System.ArgumentException]::new(
        "Cannot validate argument on parameter 'Credentials'. Incorrect GitHub credentials"
    )
}


function Get-MergedPullRequests {
    [CmdletBinding()]
    [OutputType([Object[]])]
   Param(
        [Parameter(Mandatory=$True, Position=0)]
        [ValidateScript({$_ -le (Get-Date)})]
        [DateTime]$StartDate,

        # The end date range (exclusive)
        [Parameter(Mandatory, Position=1)]
        [ValidateScript({$_ -le (Get-Date)})]
        [DateTime]$EndDate,

        [Parameter(Mandatory=$True)]
        [Credential()]
        [PSCredential]$Credentials
    )
    Begin {
        $RequestSplat = @{
            Uri = 'https://api.github.com/repos/Microsoft/vcpkg/pulls'
            Body = @{
                state = 'closed'
                sort = 'updated'
                base = 'master'
                per_page = 100
                direction = 'desc'
                page = 1
            }
        }
        $Epoch = Get-Date -AsUTC
        $DeltaEpochStart = ($Epoch - $StartDate).Ticks

        $ProgressSplat = @{
            Activity = "Searching for merged Pull Requests in date range: $($StartDate.ToString('yyyy-MM-dd')) - $($EndDate.ToString('yyyy-MM-dd'))"
            PercentComplete = 0
        }

        Write-Progress @ProgressSplat

        $writeProgress = {
            $ProgressSplat.PercentComplete = 100 * ($Epoch - $_.updated_at).Ticks / $DeltaEpochStart
            Write-Progress @ProgressSplat -Status "Current item date: $($_.updated_at.ToString('yyyy-MM-dd'))"
        }
    }
    Process {
        while ($True) {
            $response = Invoke-WebRequest -Headers (Get-AuthHeader $Credentials) @RequestSplat | ConvertFrom-Json

            foreach ($_ in $response) {
                foreach ($x in 'created_at', 'merged_at', 'updated_at', 'closed_at') {
                    if ($_.$x) { $_.$x = [DateTime]::Parse($_.$x,
                        [System.Globalization.CultureInfo]::InvariantCulture,
                        [System.Globalization.DateTimeStyles]::AdjustToUniversal -bor [System.Globalization.DateTimeStyles]::AssumeUniversal) }
                }

                if (-not $_.merged_at) { continue }
                if ($_.updated_at -lt $StartDate) { return }

                &$WriteProgress

                if ($_.merged_at -ge $EndDate -or $_.merged_at -lt $StartDate) { continue }

                $_
            }

            $RequestSplat.Body.page++
        }
    }
}


class PRFileMap {
    [Object]$Pull
    [Object[]]$Files
}


function Get-PullRequestFileMap {
    [CmdletBinding()]
    [OutputType([PRFileMap[]])]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [Object]$Pull,
        [Parameter(Mandatory=$True)]
        [Credential()]
        [PSCredential]$Credentials
    )
    Begin {
        $Pulls = [List[Object]]::new()

        $ProgressSplat = @{
            Activity = 'Getting Pull Request files'
            PercentComplete = 0
        }

        $Count = 0
        $WriteProgress = {
            $ProgressSplat.Status = 'Getting files for: #{0} ({1}/{2})' -f $_.number, $Count, $Pulls.Length
            $ProgressSplat.PercentComplete = 100 * $Count / $Pulls.Length
            Write-Progress @ProgressSplat
        }
    }
    Process {
        $Pulls += $Pull
    }
    End {
        Write-Progress @ProgressSplat
        $ProgressSplat += @{ Status = '' }

        $Pulls | ForEach-Object {
            $Count++

            [PRFileMap]@{
                Pull = $_
                Files = $(
                    $requestSplat = @{
                        Uri = 'https://api.github.com/repos/Microsoft/vcpkg/pulls/{0}/files' -f $_.number
                        Body = @{ page = 0; per_page = 100 }
                    }
                    do {
                        $requestSplat.Body.page++

                        $response = Invoke-WebRequest -Headers (Get-AuthHeader $Credentials) @requestSplat | ConvertFrom-Json

                        $response
                    } until ($response.Length -lt $requestSplat.Body.per_page)
                )
            }

            &$WriteProgress
        }
    }
}


class DocumentationUpdate {
    [String]$Path
    [Boolean]$New
    [List[Object]]$Pulls
}


function Select-Documentation {
    [CmdletBinding()]
    [OutputType([DocumentationUpdate])]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PRFileMap]$PRFileMap
    )
    Begin {
        $UpdatedDocumentation = @{}
    }
    Process {
        $PRFileMap.Files | ForEach-Object {
            if ($_.filename -notlike 'docs/*') { return }

            $new = $_.status -eq 'added'
            if ($entry = $UpdatedDocumentation[$_.filename]) {
                $entry.Pulls += $PRFileMap.Pull
                $entry.New = $entry.New -or $new
            } else {
                $UpdatedDocumentation[$_.filename] = @{
                    Pulls = [List[Object]]::new(@($PRFileMap.Pull))
                    New = $new
                }
            }
        }
    }
    End {
        $UpdatedDocumentation.GetEnumerator() | ForEach-Object {
            [DocumentationUpdate]@{
                Path = $_.Key
                Pulls = $_.Value.Pulls
                New = $_.Value.New
            }
        }
    }
}


function Select-InfrastructurePullRequests {
    [CmdletBinding()]
    [OutputType([Object])]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PRFileMap]$PRFileMap
    )
    Process {
        switch -Wildcard ($PRFileMap.Files | Foreach-Object {$_.filename}) {
            "docs/*" { continue }
            "ports/*" { continue }
            "versions/*" { continue }
            "scripts/ci.baseline.txt" { continue }
            Default { return $PRFileMap.Pull }
        }
    }
}


class Version {
    [String]$Begin
    [String]$End
    [String]$BeginPort
    [String]$EndPort
}


function Select-Version {
    [CmdletBinding()]
    [OutputType([Version])]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [Object]$VersionFile
    )
    Begin {
        $V = [Version]@{}
    }
    Process {
        $regex = switch ($VersionFile.filename | Split-Path -Leaf) {
            'CONTROL' {
                '(?<operation>^[\+|\-]|)(?<field>Version|[\+|\-]Port-Version):\s(?<version>\S+)'
            }
            'vcpkg.json' {
                '(?<operation>^[\+|\-]|)\s*(\"(?<field>version|version-date|version-string|version-semver)\":\s\"(?<version>.+)\"|\"(?<field>port-version)\":\s(?<version>.+))'
            }
            Default { return }
        }

        $VersionFile.Patch -split '\n' | ForEach-Object {
            if ($_ -notmatch $regex) { return }

            $m = $Matches
            switch -Wildcard ($m.operation + $m.field) {
                'Version*' { $V.Begin = $V.End = $m.version }
                '-Version*' { $V.Begin = ($V.Begin, $m.version | Measure-Object -Minimum).Minimum }
                '+Version*' { $V.End = ($V.End, $m.version | Measure-Object -Minimum).Minimum }
                'Port-Version' { $V.BeginPort = $V.EndPort = $m.version }
                '-Port-Version' { $V.BeginPort = ($V.BeginPort, $m.version | Measure-Object -Minimum).Minimum }
                '+Port-Version' { $V.EndPort = ($V.EndPort, $m.version | Measure-Object -Maximum).Maximum }
            }
        }
    }
    End {
        if (-not $V.Begin) { $V.Begin = $V.End }
        elseif (-not $V.End) { $V.End = $V.Begin }

        if (-not $V.BeginPort) { $V.BeginPort = '0' }
        if (-not $V.EndPort) { $V.EndPort = '0' }

        $V
    }
}


class PortUpdate {
    [String]$Port
    [Object[]]$Pulls
    [Version]$Version
    [Boolean]$New
}


function Select-UpdatedPorts {
    [CmdletBinding()]
    [OutputType([PortUpdate])]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PRFileMap]$PRFileMap
    )
    Begin {
        $ModifiedPorts = @{}
    }
    Process {
        $PRFileMap.Files | Where-Object {
            $_.filename -like 'ports/*/CONTROL' -or
            $_.filename -like 'ports/*/vcpkg.json'
        } | ForEach-Object {
            $port = $_.filename.split('/')[1]
            if ($entry = $ModifiedPorts[$port]) {
                $entry.VersionFiles += $_
                if (-not $entry.Pulls.Contains($PRFileMap.Pull)) { $entry.Pulls += $PRFileMap.Pull }
            } else {
                $ModifiedPorts[$port] = @{
                    VersionFiles = [List[Object]]::new(@($_))
                    Pulls = [List[Object]]::new(@($PRFileMap.Pull))
                }
            }
        }
    }
    End {
        $ModifiedPorts.GetEnumerator() | ForEach-Object {
            $versionFiles = $_.Value.VersionFiles
            if (-not ($versionChange = $versionFiles | Select-Version)) { return }

            function Find-File($x) { [bool]($versionFiles | Where-Object { $_.filename -like "*$x" }) }
            function Find-NewFile($x)
                { [bool]($versionFiles | Where-Object { $_.filename -like "*$x" -and $_.status -eq 'added' }) }

            [PortUpdate]@{
                Port = $_.Key
                Pulls = $_.Value.Pulls
                Version = $versionChange
                New = (Find-NewFile 'CONTROL') -or (-not (Find-File 'CONTROL') -and (Find-NewFile 'vcpkg.json'))
            }
        }
    }
}

$MergedPRs = Get-MergedPullRequests -StartDate $StartDate -EndDate $EndDate -Credentials $Credentials
$MergedPRsSorted = $MergedPRs | Sort-Object -Property 'number'
$PRFileMaps = $MergedPRsSorted | Get-PullRequestFileMap -Credentials $Credentials

$sortSplat = @{ Property =
    @{ Expression = 'New'; Descending = $True }, @{ Expression = 'Path'; Descending = $False } }
$UpdatedDocumentation = $PRFileMaps | Select-Documentation | Sort-Object @sortSplat
$UpdatedInfrastructure = $PRFileMaps | Select-InfrastructurePullRequests
$UpdatedPorts = $PRFileMaps | Select-UpdatedPorts
$NewPorts = $UpdatedPorts | Where-Object { $_.New }
$ChangedPorts = $UpdatedPorts | Where-Object { -not $_.New }

Write-Progress -Activity 'Selecting updates from pull request files' -Completed

Write-Progress -Activity 'Writing changelog file' -PercentComplete -1

$output = @"
vcpkg ($($StartDate.ToString('yyyy.MM.dd')) - $((($EndDate).AddSeconds(-1)).ToString('yyyy.MM.dd')))
---
#### Total port count:
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|x86-windows|NUM|
|**x64-windows**|NUM|
|x64-windows-static|NUM|
|x64-windows-static-md|NUM|
|x64-uwp|NUM|
|arm64-windows|NUM|
|arm-uwp|NUM|
|**x64-osx**|NUM|
|**x64-linux**|NUM|

"@

if ($UpdatedDocumentation) {
    $output += @"
#### The following documentation has been updated:

$(-join ($UpdatedDocumentation | ForEach-Object {
    $PathWithoutDocs =  ([string]$_.Path).Remove(0, 5) # 'docs/'
    "- [{0}]({0}){1}`n" -f $PathWithoutDocs, $_.Path, ($(if ($_.New) { ' ***[NEW]***' } else { '' }))

    $_.Pulls | ForEach-Object {
        "    - [(#{0})]({1}) {2} (by @{3})`n" -f $_.number, $_.html_url, $_.title, $_.user.login
    }
}))

"@
}

if ($NewPorts) {
    $output += @"
<details>
<summary><b>The following $($NewPorts.Length) ports have been added:</b></summary>

|port|version|
|---|---|
$(-join ($NewPorts | ForEach-Object {
    "|[{0}]({1})" -f $_.Port, $_.Pulls[0].html_url

    if ($_.Pulls.Length -gt 1 ) {
        '<sup>'
        $_.Pulls[1..($_.Pulls.Length - 1)] | ForEach-Object {
            "[#{0}]({1})" -f $_.number, $_.html_url
        }
        '</sup>'
    }

    "|{0}`n" -f $_.Version.End
}))
</details>

"@
}

if ($ChangedPorts) {
    $output += @"
<details>
<summary><b>The following $($ChangedPorts.Length) ports have been updated:</b></summary>

$(-join ($ChangedPorts | ForEach-Object {
    "- {0} ``{1}#{2}``" -f $_.Port, $_.Version.Begin, $_.Version.BeginPort
    ' -> '
    "``{0}#{1}```n" -f $_.Version.End, $_.Version.EndPort

    $_.Pulls | ForEach-Object {
        "    - [(#{0})]({1}) {2} (by @{3})`n" -f $_.number, $_.html_url, $_.title, $_.user.login
    }
}))
</details>

"@
}

if ($UpdatedInfrastructure) {
    $output += @"
<details>
<summary>The following additional changes have been made to vcpkg's infrastructure:</summary>

$(-join ($UpdatedInfrastructure | ForEach-Object {
    "- [(#{0})]({1}) {2} (by @{3})`n" -f $_.number, $_.html_url, $_.title, $_.user.login
}))
</details>

"@
}

$output += @"
-- vcpkg team vcpkg@microsoft.com $(Get-Date -UFormat "%a, %d %B %T %Z00")
"@

Set-Content -Value $Output -Path $OutFile

Write-Progress -Activity 'Writing changelog file' -Completed
