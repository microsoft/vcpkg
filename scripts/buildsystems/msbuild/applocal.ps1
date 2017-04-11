[cmdletbinding()]
param([string]$targetBinary, [string]$installedDir, [string]$tlogFile)

$g_searched = @{}
# Note: installedDir is actually the bin\ directory.
$g_install_root = Split-Path $installedDir -parent

# Note: this function signature is depended upon by the qtdeploy.ps1 script introduced in 5.7.1-7
function deployBinary([string]$targetBinaryDir, [string]$SourceDir, [string]$targetBinaryName) {
    if (Test-Path "$targetBinaryDir\$targetBinaryName") {
        Write-Verbose "  ${targetBinaryName}: already present"
    }
    else {
        Write-Verbose "  ${targetBinaryName}: Copying $SourceDir\$targetBinaryName"
        Copy-Item "$SourceDir\$targetBinaryName" $targetBinaryDir
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
            deployBinary $targetBinaryDir $installedDir "$_"
            if (Test-Path function:\deployPluginsIfQt) { deployPluginsIfQt $targetBinaryDir "$g_install_root\plugins" "$_" }
            resolve "$targetBinaryDir\$_"
        } else {
            Write-Verbose "  ${_}: $installedDir\$_ not found"
        }
    }
    Write-Verbose "Done Resolving $targetBinary."
}

# Note: This is a hack to make Qt5 work.
# Introduced with Qt package version 5.7.1-7
if (Test-Path "$g_install_root\plugins\qtdeploy.ps1") {
    . "$g_install_root\plugins\qtdeploy.ps1"
}

resolve($targetBinary)
Write-Verbose $($g_searched | out-string)