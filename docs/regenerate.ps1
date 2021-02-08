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

$tableOfContents = @()
$internalTableOfContents = @()

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
        [String[]]$Value,
        [String]$Name
    )
    $Value + @(
        "",
        "## Source",
        "[scripts/cmake/$Name](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/$Name)",
        ""
    )
}

Get-ChildItem "$VcpkgRoot/scripts/cmake" -Filter '*.cmake' | ForEach-Object {
    $filename = $_
    [String[]]$contents = Get-Content $filename

    if ($contents[0] -eq '# DEPRECATED') {
        return
    }

    [String]$startCommentRegex = '#\[(=*)\['
    [String]$endCommentRegex = ''
    [Bool]$inComment = $False
    [Bool]$failThisFile = $False
    [Bool]$isInternalFunction = $filename.Name.StartsWith("vcpkg_internal") -or $filename.Name.StartsWith("z_vcpkg")

    $contents = $contents | ForEach-Object {
        if (-not $inComment) {
            if ($_ -match "^\s*${startCommentRegex}(\.[a-z]*)?:?\s*$") {
                if (-not [String]::IsNullOrEmpty($matches[2]) -and $matches[2] -ne '.md') {
                    Write-Warning "The documentation in ${filename} doesn't seem to be markdown (extension: $($matches[2])). Only markdown is supported; please rewrite the documentation in markdown."
                }
                $inComment = $True
                $endCommentRegex = "\]$($matches[1])\]"
            } elseif ($_ -match $startCommentRegex) {
                $failThisFile = $True
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
                $failThisFile = $True
                Write-Warning "Invalid end of comment -- the comment end must be on it's own on a line.
    (on line: `"$_`")"
            } else {
                # regular documentation line
                $_
            }
        }
    }

    if ($inComment) {
        Write-Warning "File ${filename} has an unclosed comment."
        return
    }

    if ($failThisFile) {
        return
    }


    if ($contents) {
        if ($isInternalFunction) {
            WriteFile `
                -Path "$PSScriptRoot/maintainers/internal/$($filename.BaseName).md" `
                -Value (FinalDocFile $contents $filename.Name)

            $internalTableOfContents += $filename.BaseName
        } else {
            WriteFile `
                -Path "$PSScriptRoot/maintainers/$($filename.BaseName).md" `
                -Value (FinalDocFile $contents $filename.Name)

            $tableOfContents += $filename.BaseName
        }
    } elseif (-not $isInternalFunction) {
        # don't worry about undocumented internal functions
        Write-Warning "The cmake function in file $filename doesn't seem to have any documentation. Make sure the documentation comments are correctly written."
    }
}

$portfileFunctionsContent = @(
    '<!-- Run regenerate.ps1 to extract documentation from scripts/cmake/*.cmake -->',
    '',
    '# Portfile helper functions')

$tableOfContents | Sort-Object -Culture '' | ForEach-Object {
    $portfileFunctionsContent += "- [$($_ -replace '_','\_')]($_.md)"
}
$portfileFunctionsContent += @("", "## Internal Functions", "")
$internalTableOfContents | Sort-Object -Culture '' | ForEach-Object {
    $portfileFunctionsContent += "- [$($_ -replace '_','\_')](internal/$_.md)"
}
$portfileFunctionsContent += "" # final newline

WriteFile `
    -Path "$PSScriptRoot/maintainers/portfile-functions.md" `
    -Value $portfileFunctionsContent
