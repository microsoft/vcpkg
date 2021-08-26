# Magnum's plugin deployment strategy is that each Magnum module has a hardcoded
# set of plugin directories. Each of these directories is deployed in
# full if that Module is referenced.
#
# Note: this function signature and behavior is depended upon by applocal.ps1
function deployPluginsIfMagnum([string]$targetBinaryDir, [string]$MagnumPluginsDir, [string]$targetBinaryName) {
    Write-Verbose "Deploying magnum plugins"

    $baseDir = Split-Path $MagnumPluginsDir -parent
    $pluginsBase = Split-Path $MagnumPluginsDir -Leaf
    $binDir = "$baseDir\bin"

    function deployPlugins([string]$pluginSubdirName) {
        if (Test-Path "$MagnumPluginsDir\$pluginSubdirName") {
            Write-Verbose "  Deploying plugins directory '$pluginSubdirName'"
            New-Item "$targetBinaryDir\$pluginsBase\$pluginSubdirName" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            Get-ChildItem -Path "$MagnumPluginsDir\$pluginSubdirName\*" -Include "*.dll", "*.conf", "*.pdb" | % {
                deployBinary "$targetBinaryDir\$pluginsBase\$pluginSubdirName" "$MagnumPluginsDir\$pluginSubdirName" $_.Name
                resolve $_
            }
        } else {
            Write-Verbose "  Skipping plugins directory '$pluginSubdirName': doesn't exist"
        }
    }

    # We detect Magnum modules in use via the DLLs that contain their
    # plugin interfaces.
    if ($targetBinaryName -like "MagnumAudio.dll" -or $targetBinaryName -like "MagnumAudio-d.dll") {
        deployPlugins "audioimporters"
    } elseif ($targetBinaryName -like "MagnumText.dll" -or $targetBinaryName -like "MagnumText-d.dll") {
        deployPlugins "fonts"
        deployPlugins "fontconverters"
    } elseif ($targetBinaryName -like "MagnumTrade.dll" -or $targetBinaryName -like "MagnumTrade-d.dll") {
        deployPlugins "importers"
        deployPlugins "imageconverters"
        deployPlugins "sceneconverters"
    } elseif ($targetBinaryName -like "MagnumShaderTools.dll" -or $targetBinaryName -like "MagnumShaderTools-d.dll") {
        deployPlugins "shaderconverters"
    }
}
