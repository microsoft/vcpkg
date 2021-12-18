# This script is based on the implementation of windeployqt for qt5.7.1
#
# Qt's plugin deployment strategy is that each main Qt Module has a hardcoded
# set of plugin subdirectories. Each of these subdirectories is deployed in
# full if that Module is referenced.
#
# This hardcoded list is found inside qttools\src\windeployqt\main.cpp. For
# updating, inspect the symbols qtModuleEntries and qtModuleForPlugin.

# Note: this function signature and behavior is depended upon by applocal.ps1
function deployPluginsIfQt([string]$targetBinaryDir, [string]$QtPluginsDir, [string]$targetBinaryName) {
    $baseDir = Split-Path $QtPluginsDir -parent
    $binDir = "$baseDir\bin"

    function deployPlugins([string]$pluginSubdirName) {
        if (Test-Path "$QtPluginsDir\$pluginSubdirName") {
            Write-Verbose "  Deploying plugins directory '$pluginSubdirName'"
            New-Item "$targetBinaryDir\plugins\$pluginSubdirName" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            Get-ChildItem "$QtPluginsDir\$pluginSubdirName\*.dll" | % {
                deployBinary "$targetBinaryDir\plugins\$pluginSubdirName" "$QtPluginsDir\$pluginSubdirName" $_.Name
                resolve "$targetBinaryDir\plugins\$pluginSubdirName\$($_.Name)"
            }
        } else {
            Write-Verbose "  Skipping plugins directory '$pluginSubdirName': doesn't exist"
        }
    }

    # We detect Qt modules in use via the DLLs themselves. See qtModuleEntries in Qt to find the mapping.
    if ($targetBinaryName -match "Qt5Cored?.dll") {
        if (!(Test-Path "$targetBinaryDir\qt.conf")) {
            "[Paths]" | Out-File -encoding ascii "$targetBinaryDir\qt.conf"
        }
    } elseif ($targetBinaryName -match "Qt5Guid?.dll") {
        Write-Verbose "  Deploying platforms"
        New-Item "$targetBinaryDir\plugins\platforms" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem "$QtPluginsDir\platforms\qwindows*.dll" | % {
            deployBinary "$targetBinaryDir\plugins\platforms" "$QtPluginsDir\platforms" $_.Name
        }

        deployPlugins "accessible"
        deployPlugins "imageformats"
        deployPlugins "iconengines"
        deployPlugins "platforminputcontexts"
        deployPlugins "styles"
    } elseif ($targetBinaryName -match "Qt5Networkd?.dll") {
        deployPlugins "bearer"
        if (Test-Path "$binDir\libcrypto-1_1-x64.dll")
        {
            deployBinary "$targetBinaryDir" "$binDir" "libcrypto-1_1-x64.dll"
            deployBinary "$targetBinaryDir" "$binDir" "libssl-1_1-x64.dll"
        }
        if (Test-Path "$binDir\libcrypto-1_1.dll")
        {
            deployBinary "$targetBinaryDir" "$binDir" "libcrypto-1_1.dll"
            deployBinary "$targetBinaryDir" "$binDir" "libssl-1_1.dll"
        }
    } elseif ($targetBinaryName -match "Qt5Sqld?.dll") {
        deployPlugins "sqldrivers"
    } elseif ($targetBinaryName -match "Qt5Multimediad?.dll") {
        deployPlugins "audio"
        deployPlugins "mediaservice"
        deployPlugins "playlistformats"
    } elseif ($targetBinaryName -match "Qt5PrintSupportd?.dll") {
        deployPlugins "printsupport"
    } elseif ($targetBinaryName -match "Qt5Qmld?.dll") {
        if(!(Test-Path "$targetBinaryDir\qml"))
        {
            if (Test-Path "$binDir\..\qml") {
                cp -r "$binDir\..\qml" $targetBinaryDir
            } elseif (Test-Path "$binDir\..\..\qml") {
                cp -r "$binDir\..\..\qml" $targetBinaryDir
            } else {
                throw "FAILED"
            }
        }
    } elseif ($targetBinaryName -match "Qt5Quickd?.dll") {
        foreach ($a in @("Qt5QuickControls2", "Qt5QuickControls2d", "Qt5QuickShapes", "Qt5QuickShapesd", "Qt5QuickTemplates2", "Qt5QuickTemplates2d", "Qt5QmlWorkerScript", "Qt5QmlWorkerScriptd", "Qt5QuickParticles", "Qt5QuickParticlesd", "Qt5QuickWidgets", "Qt5QuickWidgetsd"))
        {
            if (Test-Path "$binDir\$a.dll")
            {
                deployBinary "$targetBinaryDir" "$binDir" "$a.dll"
            }
        }
        deployPlugins "scenegraph"
        deployPlugins "qmltooling"
    } elseif ($targetBinaryName -like "Qt5Declarative*.dll") {
        deployPlugins "qml1tooling"
    } elseif ($targetBinaryName -like "Qt5Positioning*.dll") {
        deployPlugins "position"
    } elseif ($targetBinaryName -like "Qt5Location*.dll") {
        deployPlugins "geoservices"
    } elseif ($targetBinaryName -like "Qt5Sensors*.dll") {
        deployPlugins "sensors"
        deployPlugins "sensorgestures"
    } elseif ($targetBinaryName -like "Qt5WebEngineCore*.dll") {
        deployPlugins "qtwebengine"
    } elseif ($targetBinaryName -like "Qt53DRenderer*.dll") {
        deployPlugins "sceneparsers"
    } elseif ($targetBinaryName -like "Qt5TextToSpeech*.dll") {
        deployPlugins "texttospeech"
    } elseif ($targetBinaryName -like "Qt5SerialBus*.dll") {
        deployPlugins "canbus"
    }
}
