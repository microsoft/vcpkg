$input = "msvc-input.json"

$input = [System.IO.Path]::Combine((Get-Location).Path, $input)

. .\get-vs-bootstrapper-json.ps1
. .\get-vs-channel-json.ps1
. .\get-vs-components-to-install.ps1

function Get-SHA256Hash {
    param (
        [string]$File
    )
    return (Get-FileHash -Algorithm SHA256 -Path $File).Hash.ToLower()
}
function Get-SHA512Hash {
    param (
        [string]$File
    )
    return (Get-FileHash -Algorithm SHA512 -Path $File).Hash.ToLower()
}

$bootstrapperJson = get-vs-bootstrapper-json -InputJson $input

$manifestJsonFile = Test-Manifest-or-Download -BootstrapperJsonFile $bootstrapperJson

$mJson = Read-Json-from-File -FilePath $manifestJsonFile

$iJson = Read-Json-from-File -FilePath $input
$configPath = $iJson.vs_config_path
$configMSBuildPath = $iJson.vs_config_path_only_msbuild

$configPath = [System.IO.Path]::Combine((Get-Location).Path, $configPath)
$configMSBuildPath = [System.IO.Path]::Combine((Get-Location).Path, $configMSBuildPath)

$configJson = Read-Json-from-File -FilePath $configPath
$vsComponents = $configJson."components"

$configMSBuildJson = Read-Json-from-File -FilePath $configMSBuildPath
$MSBuildWorkload = $configMSBuildJson."components"

$allpackages = $mJson.packages

Write-Host "Retrieving components to install..."
$installcomponents = Get-Components-To-Install -Packages $allPackages -RequestedComponents $vsComponents

Write-Host "Retrieving components to install for MSBuild..."
$MSBuildcomponents = Get-Components-To-Install -Packages $allPackages -RequestedComponents $MSBuildWorkload

WRite-Host "Finsihsed retrieving components to install..."

$winsdkcomponents = $installcomponents | Where-Object { $_.id.toLower() -match "win11sdk"}
$msbuildaddcomponents = $installcomponents | Where-Object { $_.id.toLower() -match ".msbuild" -or 
                                                            ($_.id.toLower() -match ".build") }
                                                            
$MSBuildcomponents += $msbuildaddcomponents

$MSBuildcomponents = $MSBuildcomponents | Select-Object -Unique *

$allothercomponents = $installcomponents | Where-Object { 
    -not ($_.id.toLower() -match "win11sdk") -and 
    -not ($MSBuildcomponents.id -contains $_.id) -and
    -not ($_.id.toLower() -match "microsoft.visualcpp.redist.14.latest") # duplicate
}

$sdkJsonFile = "winsdk.json"
$jsonData = $winsdkcomponents | ConvertTo-Json -Depth 10
$res = $jsonData | Set-Content -Path $sdkJsonFile

$msvcJsonFile = "toolkit.json"
$jsonData = $allothercomponents | ConvertTo-Json -Depth 10
$res = $jsonData | Set-Content -Path $msvcJsonFile

$msbuildJsonFile = "msbuild.json"
$jsonData = $MSBuildcomponents | ConvertTo-Json -Depth 10
$res = $jsonData | Set-Content -Path $msbuildJsonFile

$jsonData = $installcomponents | ConvertTo-Json -Depth 10
$res = $jsonData | Set-Content -Path install.json

$global:UsedFileNames = @()
function Write-CMake-Download-File {
    param (
        [string]$OutputCMakeFile = "download.cmake",
        [string]$Component,
        [string]$Context,
        [string]$Url,
        [string]$File,
        [string]$FileName
    )

    $cmakePrefix = "${Context}_${Component}_"
    $sha512 = Get-SHA512Hash -File $File
    $FileName = $FileName -replace '\\', '/'

    if ($global:UsedFileNames -contains $FileName) {
        throw "Error: The file name '$FileName' has already been used."
    } else {
        $global:UsedFileNames += $FileName
    }
    
    Add-Content -Path $OutputCMakeFile -Value @(`
        "`n", `
        "set(${cmakePrefix}URL `"${Url}`")", `
        "set(${cmakePrefix}SHA512 `"${sha512}`")", `
        "set(${cmakePrefix}FILENAME `"${FileName}`")", `
        "list(APPEND ${Context}_FILES ${Component})" `
        )
}

function Write-WindowsSDK-CMake {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $payloads = $jsonData.payloads

    $downloadFolderSdk = New-Item -Path $BuildFolder -ItemType Directory -Force
    $installFolderSdk = New-Item -Path $PackageFolder -ItemType Directory -Force

    $msi = @()

    
    Write-Output "Downloading Windows SDKs..."

    $sdk_cmake_file = "download_sdk.cmake"

    $counter = 0
    foreach ($payload in $payloads) {
        $filename = $payload.fileName
        $filename = Join-Path -Path $jsonData.id -ChildPath $filename
        $filePath = Join-Path -Path $downloadFolderSdk -ChildPath $filename
        $parentPath = Split-Path -Path $filePath -Parent
        if(-not (Test-Path -Path $parentPath)) {
            $newfolder = New-Item -Path $parentPath -ItemType Directory -Force
        }     
        Invoke-Download-with-Check -Url $payload.url -OutputPath $filePath -Check  $payload.sha256
        Write-CMake-Download-File -OutputCMakeFile $sdk_cmake_file `
                                  -Component "$counter" `
                                  -Context "WinSDK" `
                                  -Url $payload.url `
                                  -File $filePath `
                                  -FileName $filename
        if ($filePath -match '\.msi$') {
            $msi += $filePath
        }
        $counter++
    }
}

function Write-MSVC-Toolkit-CMake {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $vctoolkits = $jsonData

    $downloadFolderVctoolkit = New-Item -Path $BuildFolder -ItemType Directory -Force
    $installFolderVctoolkit = New-Item -Path $PackageFolder -ItemType Directory -Force

    $counter = 0
    foreach ($toolkit in $vctoolkits) {
        $payloads = $toolkit.payloads
        $id = $toolkit.id
        $id_name = $id
        if ($toolkit.PSObject.Properties["chip"] ) {
            $chip = $toolkit.chip
            $id_name += ",chip=${chip}"
        }

        foreach ($payload in $payloads) {
            $counter++
            $filename = $payload.fileName
            $filename = Join-Path -Path $id_name -ChildPath $filename
            $filePath = Join-Path -Path $downloadFolderVctoolkit -ChildPath $filename
            $parentPath = Split-Path -Path $filePath -Parent
            if(-not (Test-Path -Path $parentPath)) {
                $response = New-Item -Path $parentPath -ItemType Directory -Force
            }
            $response = Invoke-Download-with-Check -Url $payload.url -OutputPath $filePath -Check $payload.sha256
            Write-CMake-Download-File -OutputCMakeFile "download_toolkit.cmake" `
                                      -Component "${id}_${counter}" `
                                      -Context "VCToolkit" `
                                      -Url $payload.url `
                                      -File $filePath `
                                      -FileName $filename
        }
    }
}

function Write-MSBuild-CMake {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )

    $download_folder = New-Item -Path $BuildFolder -ItemType Directory -Force
    $install_folder = New-Item -Path $PackageFolder -ItemType Directory -Force
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $payloads = $jsonData

    $count=0
    foreach ($installer in $payloads) {
        Write-Host "$installer"
        if (-not $installer.PSObject.Properties["payloads"] ) {
            Write-Host "No Payloads"
            continue
        }
        $payloads = $installer.payloads
        $download_folder_msbuild = Join-Path -Path $download_folder -ChildPath "MSBuild\$($installer.id.ToLower())"
        $name = $installer.id
        if (-not (Test-Path -Path $download_folder_msbuild)) {
            $response = New-Item -ItemType Directory -Path $download_folder_msbuild -Force
        }
        foreach ($payload in $payloads) {
            $filename = $payload.fileName
            $filename = Join-Path -Path $name -ChildPath $filename
            $filepath = Join-Path -Path $download_folder_msbuild -ChildPath $filename
            $parentpath = Split-Path -Parent $filepath
            if (-not (Test-Path -Path $parentpath)) {
                $response = New-Item -ItemType Directory -Path $parentpath -Force
            }
            $response = Invoke-Download-with-Check -Url $payload.url -OutputPath $filepath -Check $payload.sha256
            Write-CMake-Download-File -OutputCMakeFile "download_msbuild.cmake" `
                                      -Component ${name} `
                                      -Context "MSBuild" `
                                      -Url $payload.url `
                                      -File $filepath `
                                      -FileName $filename           
       }
    }
}


#$InputJson = [System.IO.Path]::Combine((Get-Location).Path, $InputJson)
#$DownloadDir = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir)
$InstallDir = [System.IO.Path]::Combine((Get-Location).Path, "install")
$BuildDir = [System.IO.Path]::Combine((Get-Location).Path, "build")

Write-Host "Writing CMake files for Windows SDK..."
Write-WindowsSDK-CMake -BuildFolder $BuildDir -PackageFolder $InstallDir -JsonDataFile $sdkJsonFile
Write-Host "Writing CMake files for MSVC Toolkit..."
Write-MSVC-Toolkit-CMake -BuildFolder $BuildDir -PackageFolder $InstallDir -JsonDataFile $msvcJsonFile
Write-Host "Writing CMake files for MSBuild..."
Write-MSBuild-CMake -BuildFolder $BuildDir -PackageFolder $InstallDir -JsonDataFile $msBuildJsonFile
#Install-MSBuild -BuildFolder $buildDir -PackageFolder $installDir -JsonDataFile $msBuildJsonFile