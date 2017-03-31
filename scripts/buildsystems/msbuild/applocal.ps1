[cmdletbinding()]
param([string]$targetBinary, [string]$installedDir, [string]$tlogFile)

$g_searched = @{}

function resolve($targetBinary) {
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
            if (Test-Path "$targetBinaryDir\$_") {
                Write-Verbose "  ${_}: already present - Only recurse"
            }
            else {
                Copy-Item $installedDir\$_ $targetBinaryDir
                Write-Verbose "  ${_}: Copying $installedDir\$_"
            }
            "$targetBinaryDir\$_"
            if ($tlogFile) { Add-Content $tlogFile "$targetBinaryDir\$_" }
            resolve("$targetBinaryDir\$_")
        } else {
            Write-Verbose "  ${_}: $installedDir\$_ not found"
        }
    }
    Write-Verbose "Done Resolving $targetBinary."
}

resolve($targetBinary)
Write-Verbose $($g_searched | out-string)