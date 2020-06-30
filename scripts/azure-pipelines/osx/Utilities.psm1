#Requires -Version 6.0
Set-StrictMode -Version 2

<#
.SYNOPSIS
Returns whether the specified command exists in the current environment.

.DESCRIPTION
Get-CommandExists takes a string as a parameter,
and returns whether it exists in the current environment;
either a function, alias, or an executable in the path.
It's somewhat equivalent to `which`.

.PARAMETER Name
Specifies the name of the command which may or may not exist.

.INPUTS
System.String
    The name of the command.

.OUTPUTS
System.Boolean
    Whether the command exists.
#>
function Get-CommandExists
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param(
        [Parameter(ValueFromPipeline)]
        [String]$Name
    )

    $null -ne (Get-Command -Name $Command -ErrorAction SilentlyContinue)
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
