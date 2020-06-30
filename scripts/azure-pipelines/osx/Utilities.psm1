#Requires -Version 6.0

Set-StrictMode -Version 2

<#
.SYNOPSIS
Returns whether the specified command exists in the current environment.
#>
function Get-CommandExists
{
    [CmdletBinding()]
    [OutputType([Bool])]
    Param([String]$Command)

    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

<##>
function Get-RemoteFile
{
    [CmdletBinding(PositionalBinding=$False)]
    [OutputType([System.IO.FileInfo])]
    Param(
        [Parameter(Mandatory=$True)]
        [String]$OutFile,
        [Parameter(Mandatory=$True)]
        [String]$Uri,
        [Parameter(Mandatory=$True)]
        [String]$Sha256
    )

    Invoke-WebRequest -OutFile $OutFile -Uri $Uri
    $actualHash = Get-FileHash -Algorithm SHA256 -Path $OutFile

    if ($actualHash.Hash -ne $Sha256) {
        throw @"
Invalid hash for file $OutFile;
    expected: $Hash
    found:    $($actualHash.Hash)
Please make sure that the hash in the powershell file is correct.
"@
    }

    Get-Item $OutFile
}

<##>
function ConvertFrom-VirtualBoxExtensionPacks
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(ValueFromPipeline)]
        [String]$Line
    )

    Begin {
        $currentObject = $null
        $currentKey = ""
        $currentString = ""
    }

    Process {
        if ($Line[0] -eq ' ') {
            $currentString += "`n$($Line.Trim())"
        } else {
            if ($null -ne $currentObject) {
                $currentObject.$currentKey = $currentString
            }
            $currentKey, $currentString = $Line -Split ':'
            $currentString = $currentString.Trim()

            if ($currentKey.StartsWith('Pack no')) {
                $currentKey = 'Pack'
                if ($null -ne $currentObject) {
                    $PSCmdlet.WriteObject([PSCustomObject]$currentObject)
                }
                $currentObject = @{}
            }
        }
    }

    End {
        if ($null -ne $currentObject) {
            $currentObject.$currentKey = $currentString
            $PSCmdlet.WriteObject([PSCustomObject]$currentObject)
        }
    }
}
