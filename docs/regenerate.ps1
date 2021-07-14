#! /usr/bin/env pwsh

[CmdletBinding()]
Param(
    [String]$VcpkgRoot = ''
)

if ([String]::IsNullOrEmpty($VcpkgRoot)) {
    $VcpkgRoot = "${PSScriptRoot}/.."
}

$VcpkgRoot = Resolve-Path $VcpkgRoot

if (-not (Test-Path "$VcpkgRoot/.vcpkg-root")) {
    throw "Invalid vcpkg instance, did you forget -VcpkgRoot?"
}

class CMakeDocumentation {
    [String]$Filename
    [String[]]$ActualDocumentation
    [Bool]$IsDeprecated
    [String]$DeprecationMessage
    [String]$DeprecatedByName
    [String]$DeprecatedByPath
    [Bool]$HasError
}

[String[]]$cmakeScriptsPorts = @(
    'vcpkg-cmake'
    'vcpkg-cmake-config'
    'vcpkg-pkgconfig-get-modules'
)

[CMakeDocumentation[]]$tableOfContents = @()
[CMakeDocumentation[]]$internalTableOfContents = @()
$portTableOfContents = [ordered]@{}

function RelativeUnixPathTo
{
    Param(
        [Parameter(Mandatory)]
        [String]$Path,
        [Parameter(Mandatory)]
        [String]$Base
    )

    $Path = Resolve-Path -LiteralPath $Path
    $Base = Resolve-Path -LiteralPath $Base

    if ($IsWindows)
    {
        if ((Split-Path -Qualifier $Path) -ne (Split-Path -Qualifier $Base))
        {
            throw "It is not possible to get the relative unix path from $Base to $Path"
        }
    }

    $Path = $Path -replace '\\','/'
    $Base = $Base -replace '\\','/'

    [String[]]$PathArray = $Path -split '/'
    [String[]]$BaseArray = $Base -split '/'

    [String[]]$Result = @()

    $Idx = 0

    while ($Idx -lt $PathArray.Length -and $Idx -lt $BaseArray.Length)
    {
        if ($PathArray[$Idx] -ne $BaseArray[$Idx])
        {
            break
        }
        ++$Idx
    }

    for ($BaseIdx = $Idx; $BaseIdx -lt $BaseArray.Length; ++$BaseIdx)
    {
        $Result += '..'
    }
    for ($PathIdx = $Idx; $PathIdx -lt $PathArray.Length; ++$PathIdx)
    {
        $Result += $PathArray[$PathIdx]
    }

    $Result -join '/'
}
function WriteFile
{
    Param(
        [String[]]$Value,
        [String]$Path
    )
    # note that we use this method of getting the utf-8 bytes in order to:
    #  - have no final `r`n, which happens when Set-Content does the thing automatically on Windows
    #  - have no BOM, which happens when one uses [System.Text.Encoding]::UTF8
    [byte[]]$ValueAsBytes = (New-Object -TypeName 'System.Text.UTF8Encoding').GetBytes($Value -join "`n")
    Set-Content -Path $Path -Value $ValueAsBytes -AsByteStream
}
function FinalDocFile
{
    Param(
        [CMakeDocumentation]$Docs,
        [String]$PathToFile # something like docs/maintainers/blah.md
    )
    [String[]]$documentation = @()

    if ($Docs.ActualDocumentation.Length -eq 0)
    {
        throw "Invalid documentation: empty docs"
    }

    $documentation += $Docs.ActualDocumentation[0] # name line
    if ($Docs.IsDeprecated)
    {
        if ($null -eq $Docs.DeprecationMessage -or $Docs.DeprecationMessage -match '^ *$')
        {
            if(![string]::IsNullOrEmpty($Docs.DeprecatedByName))
            {
                $message = " in favor of [``$($Docs.DeprecatedByName)``]($($Docs.DeprecatedByPath)$($Docs.DeprecatedByName).md)"
                $Docs.DeprecatedByPath -match '^ports/([a-z\-]+)/$' | Out-Null
                $port = $matches[1]
                if(![string]::IsNullOrEmpty($port))
                {
                    $message += " from the $port port."
                }
            }
            $documentation += @("", "**This function has been deprecated$message**")
        }
        else
        {
            $documentation += @("", "**This function has been deprecated $($Docs.DeprecationMessage)**")
        }
    }
    $documentation += @("", "The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/$PathToFile).")

    $documentation += $Docs.ActualDocumentation[1..$Docs.ActualDocumentation.Length]

    $relativePath = RelativeUnixPathTo $Docs.Filename $VcpkgRoot
    $documentation += @(
        "",
        "## Source",
        "[$($relativePath -replace '_','\_')](https://github.com/Microsoft/vcpkg/blob/master/$relativePath)",
        ""
    )

    $documentation
}

function ParseCmakeDocComment
{
    Param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$Filename
    )

    $Docs = New-Object 'CMakeDocumentation'
    $Docs.HasError = $False
    $Docs.IsDeprecated = $False
    $Docs.Filename = $Filename.FullName

    [String[]]$contents = Get-Content $Filename

    if ($contents[0] -eq '# DEPRECATED')
    {
        $Docs.IsDeprecated = $True
    }
    elseif($contents[0] -match '^# DEPRECATED( BY (([^/]+/)+)(.+))?((: *)(.*))?$')
    {
        $Docs.IsDeprecated = $True
        $Docs.DeprecatedByPath = $matches[2]
        $Docs.DeprecatedByName = $matches[4]
        $Docs.DeprecationMessage = $matches[7]
    }

    [String]$startCommentRegex = '#\[(=*)\['
    [String]$endCommentRegex = ''
    [Bool]$inComment = $False

    $contents = $contents | ForEach-Object {
        if (-not $inComment) {
            if ($_ -match "^\s*${startCommentRegex}(\.[a-z]*)?:?\s*$") {
                if (-not [String]::IsNullOrEmpty($matches[2]) -and $matches[2] -ne '.md') {
                    Write-Warning "The documentation in $($Filename.FullName) doesn't seem to be markdown (extension: $($matches[2])). Only markdown is supported; please rewrite the documentation in markdown."
                }
                $inComment = $True
                $endCommentRegex = "\]$($matches[1])\]"
            } elseif ($_ -match $startCommentRegex) {
                $Docs.HasError = $True
                Write-Warning "Invalid start of comment -- the comment start must be at the beginning of the line.
    (on line: `"$_`")"
            } else {
                # do nothing -- we're outside a comment, so cmake code
            }
        } else {
            if ($_ -match "^\s*#?${endCommentRegex}\s*$") {
                $inComment = $False
                $endCommentRegex = ''
            } elseif ($_ -match $endCommentRegex) {
                $Docs.HasError = $True
                Write-Warning "Invalid end of comment -- the comment end must be on it's own on a line.
    (on line: `"$_`")"
            } else {
                # regular documentation line
                $_
            }
        }
    }

    if ($inComment) {
        Write-Warning "File $($Filename.FullName) has an unclosed comment."
        $Docs.HasError = $True
    }

    if (-not [String]::IsNullOrEmpty($contents))
    {
        $Docs.ActualDocumentation = $contents
    }

    $Docs
}

Get-ChildItem "$VcpkgRoot/scripts/cmake" -Filter '*.cmake' | ForEach-Object {
    $docs = ParseCmakeDocComment $_
    [Bool]$isInternalFunction = $_.Name.StartsWith("vcpkg_internal") -or $_.Name.StartsWith("z_vcpkg")

    if ($docs.IsDeprecated -and $null -eq $docs.ActualDocumentation)
    {
        return
    }
    if ($docs.HasError)
    {
        return
    }

    if ($null -ne $docs.ActualDocumentation)
    {
        if ($isInternalFunction)
        {
            $pathToFile = "maintainers/internal/$($_.BaseName).md"
            WriteFile `
                -Path "$PSScriptRoot/$pathToFile" `
                -Value (FinalDocFile $docs)

            $internalTableOfContents += $docs
        }
        else
        {
            $pathToFile = "maintainers/$($_.BaseName).md"
            WriteFile `
                -Path "$PSScriptRoot/$pathToFile" `
                -Value (FinalDocFile $docs $pathToFile)

            $tableOfContents += $docs
        }
    }
    elseif (-not $isInternalFunction)
    {
        # don't worry about undocumented internal functions
        Write-Warning "The cmake function in file $($_.FullName) doesn't seem to have any documentation. Make sure the documentation comments are correctly written."
    }
}

$cmakeScriptsPorts | ForEach-Object {
    $portName = $_

    Copy-Item "$VcpkgRoot/ports/$portName/README.md" "$PSScriptRoot/maintainers/ports/$portName.md"
    New-Item -Path "$PSScriptRoot/maintainers/ports/$portName" -Force -ItemType 'Directory' | Out-Null

    $portTableOfContents[$portName] = @()

    Get-ChildItem "$VcpkgRoot/ports/$portName" -Filter '*.cmake' | ForEach-Object {
        if ($_.Name -eq 'vcpkg-port-config.cmake' -or $_.Name -eq 'portfile.cmake')
        {
            return
        }

        $docs = ParseCmakeDocComment $_

        if ($docs.IsDeprecated -and $null -eq $docs.ActualDocumentation)
        {
            return
        }
        if ($docs.HasError)
        {
            return
        }

        if ($null -ne $docs.ActualDocumentation)
        {
            $pathToFile = "maintainers/ports/$portName/$($_.BaseName).md"
            WriteFile `
                -Path "$PSScriptRoot/$pathToFile" `
                -Value (FinalDocFile $docs $pathToFile)
            $portTableOfContents[$portName] += $docs
        }
        else
        {
            Write-Warning "The cmake function in file $($_.FullName) doesn't seem to have any documentation. Make sure the documentation comments are correctly written."
        }
    }
}

$portfileFunctionsContent = @(
    '<!-- Run regenerate.ps1 to extract scripts documentation -->',
    '',
    '# Portfile helper functions')

function GetDeprecationMessage
{
    Param(
        [CMakeDocumentation]$Doc
    )
    $message = ''
    if ($Doc.IsDeprecated)
    {
        $message = " (deprecated"
        if(![string]::IsNullOrEmpty($Doc.DeprecatedByName))
        {
            $message += ", use [$($($Doc.DeprecatedByName) -replace '_','\_')]($($Doc.DeprecatedByPath)$($Doc.DeprecatedByName).md)"
        }
        $message += ")"
    }
    $message
}

$DocsName = @{ expression = { Split-Path -LeafBase $_.Filename } }
$tableOfContents | Sort-Object -Property $DocsName -Culture '' | ForEach-Object {
    $name = Split-Path -LeafBase $_.Filename
    $portfileFunctionsContent += "- [$($name -replace '_','\_')]($name.md)" + $(GetDeprecationMessage $_)
}
$portfileFunctionsContent += @("", "## Internal Functions", "")
$internalTableOfContents | Sort-Object -Property $DocsName -Culture '' | ForEach-Object {
    $name = Split-Path -LeafBase $_.Filename
    $portfileFunctionsContent += "- [$($name -replace '_','\_')](internal/$name.md)" + $(GetDeprecationMessage $_)
}

$portfileFunctionsContent += @("", "## Scripts from Ports")
$portTableOfContents.GetEnumerator() | ForEach-Object {
    $portName = $_.Name
    $cmakeDocs = $_.Value
    $portfileFunctionsContent += @("", "### [$portName](ports/$portName.md)", "")
    $cmakeDocs | ForEach-Object {
        $name = Split-Path -LeafBase $_.Filename
        $portfileFunctionsContent += "- [$($name -replace '_','\_')](ports/$portName/$name.md)" + $(GetDeprecationMessage $_)
    }
}

$portfileFunctionsContent += "" # final newline

WriteFile `
    -Path "$PSScriptRoot/maintainers/portfile-functions.md" `
    -Value $portfileFunctionsContent
