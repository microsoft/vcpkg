# Note: This function signature and behavior is depended upon by applocal.ps1

function deployOpenNI2([string]$targetBinaryDir, [string]$installedDir, [string]$targetBinaryName) {
    if ($targetBinaryName -like "OpenNI2.dll") {
        if(Test-Path "$installedDir\OpenNI.ini") {
            Write-Verbose "  Deploying OpenNI2 Initialization"
            deployBinary "$targetBinaryDir" "$installedDir" "OpenNI.ini"
        }
        if(Test-Path "$installedDir\OpenNI2\Drivers") {
            Write-Verbose "  Deploying OpenNI2 Drivers"
            New-Item "$targetBinaryDir\OpenNI2\Drivers" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            Get-ChildItem "$installedDir\OpenNI2\Drivers\*.*" -include "*.dll","*.ini" | % {
                deployBinary "$targetBinaryDir\OpenNI2\Drivers" "$installedDir\OpenNI2\Drivers" $_.Name
            }
        }
    }
}

