#Requires -Version 5.0
# We are not using Powershell >= 6.0, as the only supported debugger (vscode powershell extension) breaks on complex code. See: https://github.com/PowerShell/PowerShellEditorServices/issues/1295
# This code can be run on PowerShell Core on any platform, but it is recommend to debug this code in Windows PowerShell ISE unless debugging happens to "just work" on your machine.
# Expect the fix to be out at around the end of 2020/beginning of 2021, at which point consider upgrading this script to PowerShell 7 the next time maintenance is necessary.
# -- Griffin Downs Dec 15, 2020 (@grdowns)

using namespace System.Management.Automation
using namespace System.Collections.Generic

<#
.Synopsis
   Changelog generator for vcpkg.
.DESCRIPTION
   The changelog generator uses the GitHub Pull Request and Files API's to get
   pull requests and their associated file changes over the provided date range.
   Then, the data is processed into buckets which are then presented to the user
   in a markdown file.
.EXAMPLE
   Get-Changelog
.EXAMPLE
   Get-Changelog -StartDate 11/1/20 -EndDate 12/1/20
.INPUTS
   The Credentials object.
.OUTPUTS
   A "CHANGELOG.md" file in the working directory.
#>
Param (
    # The begin date range (inclusive)
    [Parameter(Mandatory=$true)]
    [ValidateScript({$_ -le (Get-Date)})]
    [DateTime]$StartDate,
    
    # The end date range (exclusive)
    [Parameter(Mandatory=$true)]
    [ValidateScript({$_ -le (Get-Date)})]
    [DateTime]$EndDate,
    
    # GitHub credentials (username and PAT)
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Credential()]
    [PSCredential]$Credentials
)


Set-StrictMode -Version 2


function Get-AuthHeader {
    @{ Authorization = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(
        '{0}:{1}' -f ($Credentials.UserName, $Credentials.GetNetworkCredential().Password))) }
}


function Get-MergedPullRequests {
    [CmdletBinding()]
    [OutputType([Object[]])]
    Param ()
    Begin {
        $PullsUrl = 'https://api.github.com/repos/Microsoft/vcpkg/pulls'
        $Body = @{
            state = 'closed'
            sort = 'updated'
            base = 'master'
            per_page = 100
            direction = 'desc'
            # In PowerShell 7 this can be used to increment the page instead of url hacking
            #page = 1
        }
    }
    Process {
        $page = 1
        while ($true) {
            $splat = @{
                Uri = $PullsUrl + "?page=$page"
                Body = $Body
                ContentType = 'application/json'
            }
            $response = Invoke-RestMethod -Headers (Get-AuthHeader) @splat

            foreach ($_ in $response) {
                # In PowerShell 7 this automatically happens
                foreach ($x in 'created_at', 'merged_at', 'updated_at', 'closed_at') {
                    if ($_.$x) { $_.$x = [DateTime]::Parse($_.$x) }
                }

                if (-not $_.merged_at) { continue }
                if ($_.updated_at -lt $StartDate) { return }
                if ($_.merged_at -ge $EndDate -or $_.merged_at -lt $StartDate) { continue }

                $_
            }

            #$Body.page++
            $page++
        }
    }
}


class PRFileMap {
    [PSCustomObject]$Pull
    [PSCustomObject[]]$Files
}


function Get-PullRequestFileMap {
    [CmdletBinding()]
    [OutputType([PRFileMap])]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Object]$Pull
    )
    Process {
        [PRFileMap]@{
            Pull = $Pull
            Files = & {
                # The -FollowRelLink option in PowerShell 6 will automatically get all pages
                $page = 1
                $pageLength = 100
                $mergeUrl = "https://api.github.com/repos/Microsoft/vcpkg/pulls/{0}/files" -f $Pull.number
                do {
                    $splat = @{
                        Uri = $mergeUrl + "?page=$page"
                        Body = @{ per_page = $pageLength }
                        ContentType = 'application/json'
                    }
                    $response = Invoke-RestMethod -Headers (Get-AuthHeader) @splat

                    $page++
                    $response
                } until ($response.Length -lt $pageLength) 
            }
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [PRFileMap]$PRFileMap
    )
    Process {
        switch -Wildcard ($PRFileMap.Files | Get-Member filename) {
            "docs/*" { continue }
            "ports/*" { continue }
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
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
                '(?<operation>^[\+|\-]|)\s*\"(?<field>version-string|port-version)\":\s\"(?<version>.+)\"'
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
    [String[]]$Authors
}


function Select-UpdatedPorts {
    [CmdletBinding()]
    [OutputType([PortUpdate])]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [PRFileMap]$PRFileMap
    )
    Begin {
        $ModifiedPorts = @{}
    } Process {
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

            function Find-File($x) { $versionFiles | Where-Object { $_.filename -like "*$x" } }
            function Find-NewFile($x)
                { $versionFiles | Where-Object { $_.filename -like "*$x" -and $_.status -eq 'added' } }

            [PortUpdate]@{
                Port = $_.Key
                Pulls = $_.Value.Pulls
                Version = $versionChange
                New = Find-NewFile 'CONTROL' -or (-not (Find-File 'CONTROL') -and (Find-NewFile 'vcpkg.json'))
                Authors = $_.Value.Pulls | ForEach-Object { $_.user.login } | Get-Unique
            }
        }
    }
}

$PRFileMaps = Get-MergedPullRequests | Sort-Object -Property 'number' | Get-PullRequestFileMap
$UpdatedDocumentation = $PRFileMaps | Select-Documentation | Sort-Object -Property 'New' -Descending
$UpdatedInfrastructure = $PRFileMaps | Select-InfrastructurePullRequests
$UpdatedPorts = $PRFileMaps | Select-UpdatedPorts
$NewPorts = $UpdatedPorts | Where-Object { $_.New }
$ChangedPorts = $UpdatedPorts | Where-Object { -not $_.New }

@"
vcpkg ($($StartDate.ToString('yyyy.MM.dd')) - $((($EndDate).AddSeconds(-1)).ToString('yyyy.MM.dd')))
---
#### Total port count:
#### Total port count per triplet (tested):
|triplet|ports available|
|---|---|
|**x64-windows**|NUM|
|x86-windows|NUM|
|x64-windows-static|NUM|
|**x64-osx**|NUM|
|**x64-linux**|NUM|
|arm64-windows|NUM|
|x64-uwp|NUM|
|arm-uwp|NUM|

#### The following commands and options have been updated:

#### The following documentation has been updated:

$(-join ($UpdatedDocumentation | ForEach-Object {
    "- [TITLE]({0}){1}`n" -f $_.Path, (& { if ($_.New) { ' ***[NEW]***' } else { '' } })

    $_.Pulls | ForEach-Object {
        "    - [(#{0})]({1}) {2} (by @{3})`n" -f $_.number, $_.html_url, $_.title, $_.user.login
    }
}))

#### The following *remarkable* changes have been made to vcpkg's infrastructure:

<details>
<summary>The following <i>additional</i> changes have been made to vcpkg's infrastructure:</summary>

$(-join ($UpdatedInfrastructure | ForEach-Object {
    "- [(#{0})]({1}) {2} (by @{3})`n" -f $_.number, $_.html_url, $_.title, $_.user.login
}))
</details>

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

-- vcpkg team vcpkg@microsoft.com $(Get-Date -UFormat "%a, %d %B %T %Z00")
"@ | Out-File 'CHANGELOG.md'
