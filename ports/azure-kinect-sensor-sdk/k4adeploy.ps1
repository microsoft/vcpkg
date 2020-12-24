# Note: This function signature and behavior is depended upon by applocal.ps1

function deployAzureKinectSensorSDK([string]$targetBinaryDir, [string]$installedDir, [string]$targetBinaryName) {
    if ($targetBinaryName -like "k4a.dll") {
        if(Test-Path "$installedDir\tools\azure-kinect-sensor-sdk\depthengine_2_0.dll") {
            Write-Verbose "  Deploying Azure Kinect Sensor SDK Initialization"
            deployBinary "$targetBinaryDir" "$installedDir\tools\azure-kinect-sensor-sdk\" "depthengine_2_0.dll"
        }
    }
}
