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

Set-Content `
    -Path "$PSScriptRoot/maintainers/portfile-functions.md" `
    -Value "<!-- Run regenerate.ps1 to extract documentation from scripts/cmake/*.cmake -->`n`n# Portfile helper functions"

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
        Set-Content -Path "$PSScriptRoot/maintainers/$($filename.BaseName).md" -Value "$($contents -join "`n")`n`n## Source`n[scripts/cmake/$($filename.Name)](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/$($filename.Name))"
        "- [$($filename.BaseName -replace "_","\_")]($($filename.BaseName).md)" `
        | Out-File -Enc Ascii -Append -FilePath "$PSScriptRoot/maintainers/portfile-functions.md"
    } elseif (-not $filename.Name.StartsWith("vcpkg_internal")) {
        # don't worry about undocumented internal functions
        Write-Warning "The cmake function in file $filename doesn't seem to have any documentation. Make sure the documentation comments are correctly written."
    }
}
