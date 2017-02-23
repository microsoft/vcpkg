[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)][string]$startingDir,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)][string]$filename
)

$ErrorActionPreference = "Stop"
$currentDir = $startingDir

while (!($currentDir -eq "") -and !(Test-Path "$currentDir\$filename"))
{
    Write-Verbose "Examining $currentDir for $filename"
    $currentDir = Split-path $currentDir -Parent
}
Write-Verbose "Examining $currentDir for $filename - Found"
return $currentDir