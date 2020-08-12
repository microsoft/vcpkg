[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Directory
)

git status --porcelain $Directory | ForEach-Object {
    (-split $_)[1]
}
