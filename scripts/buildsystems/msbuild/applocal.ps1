[cmdletbinding()]
param([string]$targetBinary, [string]$installedDir, [string]$tlogFile)

$g_searched = @{}

function deployBinary([string]$targetBinaryDir, [string]$targetBinaryName) {
    if (Test-Path "$targetBinaryDir\$targetBinaryName") {
        Write-Verbose "  ${targetBinaryName}: already present - Only recurse"
    }
    else {
        Copy-Item "$installedDir\$targetBinaryName" $targetBinaryDir
        Write-Verbose "  ${targetBinaryName}: Copying $installedDir\$targetBinaryName"
    }
    "$targetBinaryDir\$targetBinaryName"
    if ($tlogFile) { Add-Content $tlogFile "$targetBinaryDir\$targetBinaryName" }
}

function resolve([string]$targetBinary) {
    Write-Verbose "Resolving $targetBinary..."
    try
    {
        $targetBinaryPath = Resolve-Path $targetBinary -erroraction stop
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        return
    }
    $targetBinaryDir = Split-Path $targetBinaryPath -parent

    $a = $(dumpbin /DEPENDENTS $targetBinary | ? { $_ -match "^    [^ ].*\.dll" } | % { $_ -replace "^    ","" })
    $a | % {
        if ([string]::IsNullOrEmpty($_)) {
            return
        }
        if ($g_searched.ContainsKey($_)) {
            Write-Verbose "  ${_}: previously searched - Skip"
            return
        }
        $g_searched.Set_Item($_, $true)
        if (Test-Path "$installedDir\$_") {
            deployBinary($targetBinaryDir, $_)
            resolve("$targetBinaryDir\$_")
        } else {
            Write-Verbose "  ${_}: $installedDir\$_ not found"
        }
    }
    Write-Verbose "Done Resolving $targetBinary."
}

resolve($targetBinary)
Write-Verbose $($g_searched | out-string)