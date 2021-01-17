[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Root
)

$Root = Resolve-Path -LiteralPath $Root

$clangFormat = Get-Command 'clang-format' -ErrorAction 'SilentlyContinue'
if ($null -ne $clangFormat)
{
    $clangFormat = $clangFormat.Source
}

if ($IsWindows)
{
    if ([String]::IsNullOrEmpty($clangFormat) -or -not (Test-Path $clangFormat))
    {
        $clangFormat = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\Llvm\x64\bin\clang-format.exe'
    }
    if (-not (Test-Path $clangFormat))
    {
        $clangFormat = 'C:\Program Files\LLVM\bin\clang-format.exe'
    }
}

if ([String]::IsNullOrEmpty($clangFormat) -or -not (Test-Path $clangFormat))
{
    Write-Error 'clang-format not found; is it installed?'
    throw
}

$toolsrc = Get-Item "$Root/toolsrc"
Push-Location $toolsrc

try
{
    $files = Get-ChildItem -Recurse -LiteralPath "$toolsrc/src" -Filter '*.cpp'
    $files += Get-ChildItem -Recurse -LiteralPath "$toolsrc/src" -Filter '*.c'
    $files += Get-ChildItem -Recurse -LiteralPath "$toolsrc/include/vcpkg" -Filter '*.h'
    $files += Get-ChildItem -Recurse -LiteralPath "$toolsrc/include/vcpkg-test" -Filter '*.h'
    $files += Get-Item "$toolsrc/include/pch.h"
    $fileNames = $files.FullName

    & $clangFormat -style=file -i @fileNames
}
finally
{
    Pop-Location
}
