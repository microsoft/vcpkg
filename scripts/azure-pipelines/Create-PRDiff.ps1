[CmdletBinding(PositionalBinding=$False)]
Param(
    [Parameter(Mandatory=$True)]
    [String]$DiffFile
)

Start-Process -FilePath 'git' -ArgumentList 'diff' `
    -NoNewWindow -Wait `
    -RedirectStandardOutput $DiffFile
if (0 -ne (Get-Item -LiteralPath $DiffFile).Length)
{
    $msg = @(
        'The formatting of the files in the repo were not what we expected,',
        'or the documentation was not regenerated.',
        'Please access the diff from format.diff in the build artifacts,'
        'and apply the patch with `git apply`'
    )
    Write-Error ($msg -join "`n")
    throw
}