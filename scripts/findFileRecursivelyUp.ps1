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
    Write-Verbose "Examining: $currentDir"
    $currentDir = Split-path $currentDir -Parent
}
Write-Verbose "Found: $currentDir"
return $currentDir